//
//  LZMADecoder.swift
//  GiniCaptureSDK
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

    /// Decompresses a raw LZMA1 bitstream using the bysquare fixed parameters.
    ///
    /// - Parameters:
    ///   - input:        Raw LZMA1 compressed bytes. The first byte must be `0x00`
    ///                   (mandatory range-coder invariant); bytes 1–4 are the initial
    ///                   range-coder `code` value (big-endian).
    ///   - outputLength: Expected decompressed byte count.
    /// - Returns: Exactly `outputLength` decompressed bytes, or `nil` on any error.
    static func decode(input: [UInt8], outputLength: Int) -> [UInt8]? {
        guard outputLength > 0 else { return [] }
        guard input.count >= 5, input[0] == 0x00 else { return nil }

        var p = Probs()
        var rc = RangeDecoder(input: input)

        // Sliding-window dictionary (ring buffer)
        var dict = [UInt8](repeating: 0, count: dictSize)
        var dictPos = 0         // total bytes written; use (dictPos & dictMask) to index dict

        // LZMA state
        var state = 0
        var rep0: UInt32 = 0, rep1: UInt32 = 0,
            rep2: UInt32 = 0, rep3: UInt32 = 0

        var output = [UInt8]()
        output.reserveCapacity(outputLength)

        while output.count < outputLength {
            let posState = dictPos & posStateMask       // dictPos & 3 for pb=2

            if rc.decodeBit(probs: &p.isMatch, index: state * numPosStates + posState) == 0 {

                // ── LITERAL ─────────────────────────────────────────────────────────
                let prevByte: UInt8 = dictPos > 0 ? dict[(dictPos - 1) & dictMask] : 0
                // litState = prevByte >> (8 - lc) = prevByte >> 5 (lp=0, lc=3)
                let litState = Int(prevByte) >> (8 - lc)
                let base = 0x300 * litState

                var sym = 1
                if state >= 7 {
                    // Matched-literal: use context from last-match position
                    var matchByte = dict[(dictPos - Int(rep0) - 1) & dictMask]
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

                let byte = UInt8(sym & 0xFF)
                dict[dictPos & dictMask] = byte
                dictPos += 1
                output.append(byte)
                state = litNextState[state]

            } else {

                // ── MATCH or REP ─────────────────────────────────────────────────────
                let len: Int

                if rc.decodeBit(probs: &p.isRep, index: state) == 0 {

                    // ── NEW MATCH (new back-reference distance) ──────────────────────
                    rep3 = rep2; rep2 = rep1; rep1 = rep0

                    let rawLen = rc.decodeLen(choice: &p.matchLenChoice,
                                             low:    &p.matchLenLow,
                                             mid:    &p.matchLenMid,
                                             high:   &p.matchLenHigh,
                                             posState: posState)
                    len = rawLen + kMatchMinLen
                    let lenState = min(rawLen, numLenToPosStates - 1)
                    let posSlot = rc.decodeBitTree(probs: &p.posSlotProbs,
                                                   offset: lenState * numPosSlots,
                                                   numBits: numPosSlotBits)
                    var dist: UInt32
                    if posSlot < kStartPosModelIndex {
                        // Slots 0–3: distance equals slot number
                        dist = UInt32(posSlot)
                    } else {
                        let numDirBits = (posSlot >> 1) - 1

                        if posSlot < kEndPosModelIndex {
                            // Slots 4–13: decode remaining bits via the special-position model
                            let distBase = (2 | (posSlot & 1)) << numDirBits
                            let specOff  = distBase - posSlot - 1   // offset into specProbs
                            dist = UInt32(distBase)
                            dist |= UInt32(rc.decodeReverseBitTree(probs: &p.specProbs,
                                                                    offset: specOff,
                                                                    numBits: numDirBits))
                        } else {
                            // Slots 14+: (numDirBits - 4) direct bits + 4 align bits
                            let distBase = (2 | (posSlot & 1))
                            let directBits = rc.decodeDirectBits(numBits: numDirBits - numAlignBits)
                            dist  = UInt32(distBase) << UInt32(numDirBits)
                            dist |= UInt32(directBits) << UInt32(numAlignBits)
                            dist |= UInt32(rc.decodeReverseBitTree(probs: &p.alignProbs,
                                                                    offset: -1,
                                                                    numBits: numAlignBits))
                        }
                    }
                    rep0  = dist
                    state = matchNextState[state]

                } else {

                    // ── REP (reuse a saved back-reference distance) ──────────────────
                    if rc.decodeBit(probs: &p.isRepG0, index: state) == 0 {
                        if rc.decodeBit(probs: &p.isRep0Long,
                                        index: state * numPosStates + posState) == 0 {
                            // Short rep: copy exactly 1 byte from distance rep0
                            let b = dict[(dictPos - Int(rep0) - 1) & dictMask]
                            dict[dictPos & dictMask] = b
                            dictPos += 1
                            output.append(b)
                            state = shortRepNextState[state]
                            continue
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
                    len   = rawLen + kMatchMinLen
                    state = repNextState[state]
                }

                // Copy `len` bytes from the dictionary at distance rep0
                for _ in 0..<len {
                    guard output.count < outputLength else { break }
                    let b = dict[(dictPos - Int(rep0) - 1) & dictMask]
                    dict[dictPos & dictMask] = b
                    dictPos += 1
                    output.append(b)
                }
            }
        }

        return output.count == outputLength ? output : nil
    }

    // MARK: – Fixed bysquare parameters

    private static let lc             = 3
    private static let lp             = 0
    private static let pb             = 2
    private static let posStateMask   = (1 << pb) - 1          // 3
    private static let numPosStates   = 1 << pb                // 4
    private static let dictSize       = 131_072                // 128 KB
    private static let dictMask       = dictSize - 1           // 0x1FFFF
    private static let kMatchMinLen   = 2
    private static let numPosSlotBits = 6
    private static let numPosSlots    = 1 << numPosSlotBits    // 64
    private static let numLenToPosStates = 4
    private static let numAlignBits   = 4
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

// MARK: – Range Decoder

private struct RangeDecoder {

    private static let topMask:       UInt32 = 0xFF00_0000
    private static let bitModelTotal: UInt32 = 2048
    private static let numMoveBits            = 5

    var range: UInt32 = 0xFFFF_FFFF
    var code:  UInt32
    var input: [UInt8]
    var pos:   Int = 5

    init(input: [UInt8]) {
        self.input = input
        // First byte (index 0) is always 0x00 in valid LZMA1 streams.
        // Bytes 1–4 initialise the range-coder 'code' register (big-endian).
        code = UInt32(input[1]) << 24 | UInt32(input[2]) << 16
             | UInt32(input[3]) << 8  | UInt32(input[4])
    }

    // Bring range back above the top-byte boundary
    private mutating func normalize() {
        if range & Self.topMask == 0 {
            range <<= 8
            let next: UInt32 = pos < input.count ? UInt32(input[pos]) : 0
            code = (code << 8) | next
            pos += 1
        }
    }

    // Decode one probability-modelled bit; updates the probability in place
    mutating func decodeBit(probs: inout [UInt16], index: Int) -> Int {
        let prob  = UInt32(probs[index])
        let bound = (range >> 11) * prob
        if code < bound {
            range = bound
            probs[index] += UInt16((Self.bitModelTotal - prob) >> Self.numMoveBits)
            normalize()
            return 0
        } else {
            range -= bound
            code  -= bound
            probs[index] -= UInt16(prob >> Self.numMoveBits)
            normalize()
            return 1
        }
    }

    // Standard (big-endian) bit tree: MSB decoded first; result in 0..(2^numBits - 1)
    mutating func decodeBitTree(probs: inout [UInt16], offset: Int, numBits: Int) -> Int {
        var m = 1
        for _ in 0..<numBits {
            m = (m << 1) | decodeBit(probs: &probs, index: offset + m)
        }
        return m - (1 << numBits)
    }

    // Reverse bit tree: LSB decoded first; result has bit-0 from the first decoded bit
    mutating func decodeReverseBitTree(probs: inout [UInt16], offset: Int, numBits: Int) -> Int {
        var m = 1, sym = 0
        for i in 0..<numBits {
            let bit = decodeBit(probs: &probs, index: offset + m)
            m   = (m << 1) | bit
            sym |= bit << i
        }
        return sym
    }

    // Uniform-probability bits (no probability model)
    mutating func decodeDirectBits(numBits: Int) -> Int {
        var result = 0
        for _ in 0..<numBits {
            range >>= 1
            code &-= range                          // wrapping subtract
            // If code underflowed (was < range), restore it and record a 1-bit
            let underflow = Int(code >> 31)         // 1 if MSB set after subtract
            if underflow != 0 { code &+= range }
            result = (result << 1) | underflow
            normalize()
        }
        return result
    }

    // Three-tier length coder; returns 0..(kNumLowLenSymbols + kNumMidLenSymbols + kNumHighLenSymbols - 1)
    // The caller adds kMatchMinLen (= 2) to obtain the actual match/rep length.
    mutating func decodeLen(choice:   inout [UInt16],
                            low:      inout [UInt16],
                            mid:      inout [UInt16],
                            high:     inout [UInt16],
                            posState: Int) -> Int {
        if decodeBit(probs: &choice, index: 0) == 0 {
            // Low tier: 8 symbols (3 bits)
            return decodeBitTree(probs: &low, offset: posState * 8, numBits: 3)
        }
        if decodeBit(probs: &choice, index: 1) == 0 {
            // Mid tier: 8 symbols (3 bits)
            return 8 + decodeBitTree(probs: &mid, offset: posState * 8, numBits: 3)
        }
        // High tier: 256 symbols (8 bits)
        return 16 + decodeBitTree(probs: &high, offset: 0, numBits: 8)
    }
}
