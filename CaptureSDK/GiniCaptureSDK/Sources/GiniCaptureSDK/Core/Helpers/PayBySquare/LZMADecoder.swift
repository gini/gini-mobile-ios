//
//  LZMADecoder.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
//  Pure Swift LZMA1 decoder for the bysquare QR payment format.
//  Parameters are fixed to the values mandated by the bysquare specification:
//  lc = 3, lp = 0, pb = 2, dictSize = 131 072 (128 KB).
//
//  Based on the public-domain LZMA SDK reference by Igor Pavlov
//  (https://www.7-zip.org/sdk.html).
//
//  Apple's Compression framework (COMPRESSION_LZMA) only decodes XZ/LZMA2 streams
//  and cannot decode the LZMA1 "alone" format used by bysquare.
//

import Foundation

enum LZMADecoder {

    // MARK: – Public entry point

    /**
     Decompresses a raw LZMA1 bitstream using the bysquare fixed parameters.
     - Parameters:
       - input: Raw LZMA1 compressed bytes. The first byte must be `0x00`
         (mandatory range-coder invariant); bytes 1–4 are the initial
         range-coder `code` value (big-endian).
       - outputLength: Expected decompressed byte count.
     - Returns: Exactly `outputLength` decompressed bytes, or `nil` on any error.
     */
    static func decode(input: [UInt8], outputLength: Int) -> [UInt8]? {
        guard outputLength > 0 else { return [] }
        guard input.count >= 5, input[0] == 0x00 else { return nil }

        var machine = Machine(input: input, outputLength: outputLength)
        return machine.run()
    }
}

// MARK: – Decoder state machine

/**
 Holds the full mutable state of an in-progress LZMA1 decode and drives the
 decode loop. Splitting the loop body across `decodeLiteral`, `decodeNewMatch`,
 `decodeRep` and `copyMatch` keeps each step's branching small and isolated.
 */
private struct Machine {

    // MARK: – Fixed bysquare parameters

    private static let lc                  = 3
    private static let pb                  = 2
    private static let posStateMask        = (1 << pb) - 1          // 3
    private static let numPosStates        = 1 << pb                // 4
    private static let dictSize            = 131_072                // 128 KB
    private static let dictMask            = dictSize - 1           // 0x1FFFF
    private static let kMatchMinLen        = 2
    private static let numPosSlotBits      = 6
    private static let numPosSlots         = 1 << numPosSlotBits    // 64
    private static let numLenToPosStates   = 4
    private static let numAlignBits        = 4
    private static let kStartPosModelIndex = 4
    private static let kEndPosModelIndex   = 14

    // MARK: – State transition tables (indexed 0..11)

    // After literal: {0,0,0,0,1,2,3,4,5,6,4,5}
    private static let litNextState:      [Int] = [0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 4, 5]
    // After new match: states < 7 → 7, states 7..11 → 10
    private static let matchNextState:    [Int] = [7, 7, 7, 7, 7, 7, 7, 10, 10, 10, 10, 10]
    // After rep (length > 1): states < 7 → 8, else → 11
    private static let repNextState:      [Int] = [8, 8, 8, 8, 8, 8, 8, 11, 11, 11, 11, 11]
    // After short rep (length == 1): states < 7 → 9, else → 11
    private static let shortRepNextState: [Int] = [9, 9, 9, 9, 9, 9, 9, 11, 11, 11, 11, 11]

    // MARK: – Mutable state

    private var p = Probs()
    private var rc: RangeDecoder
    private let outputLength: Int

    // Sliding-window dictionary (ring buffer)
    private var dict = [UInt8](repeating: 0, count: Machine.dictSize)
    private var dictPos = 0      // total bytes written; use (dictPos & dictMask) to index dict

    // LZMA state
    private var state = 0
    private var rep0: UInt32 = 0, rep1: UInt32 = 0,
                rep2: UInt32 = 0, rep3: UInt32 = 0

    private var output = [UInt8]()

    init(input: [UInt8],
         outputLength: Int) {
        self.rc = RangeDecoder(input: input)
        self.outputLength = outputLength
        output.reserveCapacity(outputLength)
    }

    // MARK: – Decode loop

    mutating func run() -> [UInt8]? {
        while output.count < outputLength {
            let posState = dictPos & Self.posStateMask  // dictPos & 3 for pb=2

            if rc.decodeBit(probs: &p.isMatch, index: state * Self.numPosStates + posState) == 0 {
                decodeLiteral()
            } else if let len = decodeMatchOrRep(posState: posState) {
                copyMatch(len: len)
            }
        }
        return output.count == outputLength ? output : nil
    }

    // MARK: – Literal

    private mutating func decodeLiteral() {
        let prevByte: UInt8 = dictPos > 0 ? dict[(dictPos - 1) & Self.dictMask] : 0
        // litState = prevByte >> (8 - lc) = prevByte >> 5 (lp=0, lc=3)
        let litState = Int(prevByte) >> (8 - Self.lc)
        let base = 0x300 * litState

        var sym = 1
        if state >= 7 {
            // Matched-literal: use context from last-match position
            var matchByte = dict[(dictPos - Int(rep0) - 1) & Self.dictMask]
            while sym < 0x100 {
                let matchBit = Int(matchByte >> 7) & 1
                matchByte <<= 1
                let bit = rc.decodeBit(probs: &p.litProbs,
                                       index: base + ((1 + matchBit) << 8) + sym)
                sym = (sym << 1) | bit
                if matchBit != bit { break }    // divergence → switch to plain decode
            }
        }
        while sym < 0x100 {
            sym = (sym << 1) | rc.decodeBit(probs: &p.litProbs, index: base + sym)
        }

        appendByte(UInt8(sym & 0xFF))
        state = Self.litNextState[state]
    }

    // MARK: – Match / Rep

    /**
     Decodes a match or rep. Returns the number of bytes to copy, or `nil` when
     a short rep (single byte) has already been emitted and no copy is needed.
     */
    private mutating func decodeMatchOrRep(posState: Int) -> Int? {
        if rc.decodeBit(probs: &p.isRep, index: state) == 0 {
            return decodeNewMatch(posState: posState)
        }
        return decodeRep(posState: posState)
    }

    /**
     New match: shift the rep history, decode a fresh back-reference distance.
     */
    private mutating func decodeNewMatch(posState: Int) -> Int {
        rep3 = rep2; rep2 = rep1; rep1 = rep0

        let rawLen = rc.decodeLen(choice: &p.matchLenChoice,
                                  low:    &p.matchLenLow,
                                  mid:    &p.matchLenMid,
                                  high:   &p.matchLenHigh,
                                  posState: posState)
        let lenState = min(rawLen, Self.numLenToPosStates - 1)
        let posSlot = rc.decodeBitTree(probs: &p.posSlotProbs,
                                       offset: lenState * Self.numPosSlots,
                                       numBits: Self.numPosSlotBits)
        rep0 = decodeDistance(posSlot: posSlot)
        state = Self.matchNextState[state]
        return rawLen + Self.kMatchMinLen
    }

    /**
     Decodes the back-reference distance for a new match from its position slot.
     */
    private mutating func decodeDistance(posSlot: Int) -> UInt32 {
        if posSlot < Self.kStartPosModelIndex {
            // Slots 0–3: distance equals slot number
            return UInt32(posSlot)
        }

        let numDirBits = (posSlot >> 1) - 1
        if posSlot < Self.kEndPosModelIndex {
            // Slots 4–13: decode remaining bits via the special-position model
            let distBase = (2 | (posSlot & 1)) << numDirBits
            let specOff  = distBase - posSlot - 1   // offset into specProbs
            var dist = UInt32(distBase)
            dist |= UInt32(rc.decodeReverseBitTree(probs: &p.specProbs,
                                                    offset: specOff,
                                                    numBits: numDirBits))
            return dist
        }

        // Slots 14+: (numDirBits - 4) direct bits + 4 align bits
        let distBase = (2 | (posSlot & 1))
        let directBits = rc.decodeDirectBits(numBits: numDirBits - Self.numAlignBits)
        var dist = UInt32(distBase) << UInt32(numDirBits)
        dist |= UInt32(directBits) << UInt32(Self.numAlignBits)
        dist |= UInt32(rc.decodeReverseBitTree(probs: &p.alignProbs,
                                               offset: -1,
                                               numBits: Self.numAlignBits))
        return dist
    }

    /**
     Rep: reuse a saved back-reference distance. Returns the copy length, or
     `nil` if a short rep was handled inline.
     */
    private mutating func decodeRep(posState: Int) -> Int? {
        if rc.decodeBit(probs: &p.isRepG0, index: state) == 0 {
            if rc.decodeBit(probs: &p.isRep0Long,
                            index: state * Self.numPosStates + posState) == 0 {
                // Short rep: copy exactly 1 byte from distance rep0
                appendByte(dict[(dictPos - Int(rep0) - 1) & Self.dictMask])
                state = Self.shortRepNextState[state]
                return nil
            }
            // Long rep0 — distance stays as rep0, fall through to copy
        } else if rc.decodeBit(probs: &p.isRepG1, index: state) == 0 {
            swap(&rep0, &rep1)
        } else if rc.decodeBit(probs: &p.isRepG2, index: state) == 0 {
            let tmp = rep2; rep2 = rep1; rep1 = rep0; rep0 = tmp
        } else {
            let tmp = rep3; rep3 = rep2; rep2 = rep1; rep1 = rep0; rep0 = tmp
        }

        let rawLen = rc.decodeLen(choice: &p.repLenChoice,
                                  low:    &p.repLenLow,
                                  mid:    &p.repLenMid,
                                  high:   &p.repLenHigh,
                                  posState: posState)
        state = Self.repNextState[state]
        return rawLen + Self.kMatchMinLen
    }

    // MARK: – Output helpers

    /**
     Copies `len` bytes from the dictionary at distance rep0 into the output.
     */
    private mutating func copyMatch(len: Int) {
        for _ in 0..<len {
            guard output.count < outputLength else { break }
            appendByte(dict[(dictPos - Int(rep0) - 1) & Self.dictMask])
        }
    }

    /**
     Writes a byte to both the sliding-window dictionary and the output stream.
     */
    private mutating func appendByte(_ byte: UInt8) {
        dict[dictPos & Self.dictMask] = byte
        dictPos += 1
        output.append(byte)
    }

    // MARK: – Probability tables

    // All tables initialised to the LZMA midpoint probability (1024 = 2048 / 2).
    private struct Probs {
        // 0x300 entries per literal state; (lc+lp)=3 → 8 literal states → 6144 total
        var litProbs       = [UInt16](repeating: 1024, count: 6144)
        var isMatch        = [UInt16](repeating: 1024, count: 48)   // 12 states × 4 pos-states
        var isRep          = [UInt16](repeating: 1024, count: 12)
        var isRepG0        = [UInt16](repeating: 1024, count: 12)
        var isRepG1        = [UInt16](repeating: 1024, count: 12)
        var isRepG2        = [UInt16](repeating: 1024, count: 12)
        var isRep0Long     = [UInt16](repeating: 1024, count: 48)   // 12 × 4
        var posSlotProbs   = [UInt16](repeating: 1024, count: 256)  // 4 len-states × 64 slots
        // specProbs: 114 entries spanning slots 4..13 (2+2+4+4+8+8+16+16+32+32)
        var specProbs      = [UInt16](repeating: 1024, count: 114)
        var alignProbs     = [UInt16](repeating: 1024, count: 16)   // 4-bit align bit-tree
        // Length coders (match and rep share the same structure)
        var matchLenChoice = [UInt16](repeating: 1024, count: 2)
        var matchLenLow    = [UInt16](repeating: 1024, count: 32)   // 4 pos-states × 8 symbols
        var matchLenMid    = [UInt16](repeating: 1024, count: 32)
        var matchLenHigh   = [UInt16](repeating: 1024, count: 256)
        var repLenChoice   = [UInt16](repeating: 1024, count: 2)
        var repLenLow      = [UInt16](repeating: 1024, count: 32)
        var repLenMid      = [UInt16](repeating: 1024, count: 32)
        var repLenHigh     = [UInt16](repeating: 1024, count: 256)
    }
}
