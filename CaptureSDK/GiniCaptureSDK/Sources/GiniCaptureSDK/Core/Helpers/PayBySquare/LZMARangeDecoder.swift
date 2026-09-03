//
//  LZMARangeDecoder.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 Arithmetic (range) decoder for an LZMA1 bitstream.
 Decodes probability-modelled bits, bit trees, direct bits, and the three-tier
 length coder that `Machine` composes into literals and matches.
 */
struct RangeDecoder {

    private static let topMask:       UInt32 = 0xFF00_0000
    private static let bitModelTotal: UInt32 = 2048
    private static let numMoveBits            = 5

    var range: UInt32 = 0xFFFF_FFFF
    var code:  UInt32
    var input: [UInt8]
    var pos:   Int = 5

    /**
     Creates a decoder positioned at the start of the range-coder stream.
     - Parameter input: Raw LZMA1 bytes. Byte 0 is always `0x00`; bytes 1–4
       initialise the `code` register (big-endian).
     */
    init(input: [UInt8]) {
        self.input = input
        // First byte (index 0) is always 0x00 in valid LZMA1 streams.
        // Bytes 1–4 initialise the range-coder 'code' register (big-endian).
        code = UInt32(input[1]) << 24 | UInt32(input[2]) << 16
             | UInt32(input[3]) << 8  | UInt32(input[4])
    }

    /**
     Brings `range` back above the top-byte boundary, pulling in a fresh input byte.
     */
    private mutating func normalize() {
        if range & Self.topMask == 0 {
            range <<= 8
            let next: UInt32 = pos < input.count ? UInt32(input[pos]) : 0
            code = (code << 8) | next
            pos += 1
        }
    }

    /**
     Decodes one probability-modelled bit and updates the probability in place.
     - Parameters:
       - probs: The probability table to read and update.
       - index: The entry within `probs` for this bit.
     - Returns: The decoded bit, `0` or `1`.
     */
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

    /**
     Decodes a standard (big-endian) bit tree, most-significant bit first.
     - Parameters:
       - probs: The probability table backing the tree.
       - offset: The base offset into `probs`.
       - numBits: The tree depth.
     - Returns: A value in `0..<(1 << numBits)`.
     */
    mutating func decodeBitTree(probs: inout [UInt16], offset: Int, numBits: Int) -> Int {
        var m = 1
        for _ in 0..<numBits {
            m = (m << 1) | decodeBit(probs: &probs, index: offset + m)
        }
        return m - (1 << numBits)
    }

    /**
     Decodes a reverse bit tree, least-significant bit first.
     - Parameters:
       - probs: The probability table backing the tree.
       - offset: The base offset into `probs`.
       - numBits: The tree depth.
     - Returns: The reassembled value with bit 0 taken from the first decoded bit.
     */
    mutating func decodeReverseBitTree(probs: inout [UInt16], offset: Int, numBits: Int) -> Int {
        var m = 1, sym = 0
        for i in 0..<numBits {
            let bit = decodeBit(probs: &probs, index: offset + m)
            m   = (m << 1) | bit
            sym |= bit << i
        }
        return sym
    }

    /**
     Decodes uniform-probability bits that use no probability model.
     - Parameter numBits: The number of direct bits to read.
     - Returns: The assembled value.
     */
    mutating func decodeDirectBits(numBits: Int) -> Int {
        var result = 0
        for _ in 0..<numBits {
            range >>= 1
            code &-= range                          // wrapping subtract
            // If code underflowed (was < range), restore it and record a 0-bit;
            // otherwise the bit is 1. This matches the LZMA reference decoder,
            // where the decoded bit is the inverse of the underflow flag.
            let underflow = Int(code >> 31)         // 1 if MSB set after subtract
            if underflow != 0 { code &+= range }
            result = (result << 1) | (1 &- underflow)
            normalize()
        }
        return result
    }

    /**
     Decodes the three-tier length coder. The caller adds `kMatchMinLen` (= 2) to
     obtain the actual match/rep length.
     - Parameters:
       - choice: The two-entry tier-selection table.
       - low: The low-tier (8-symbol) table.
       - mid: The mid-tier (8-symbol) table.
       - high: The high-tier (256-symbol) table.
       - posState: The position state selecting the low/mid sub-tree.
     - Returns: A length symbol before `kMatchMinLen` is added.
     */
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
