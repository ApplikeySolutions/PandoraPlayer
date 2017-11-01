//
//  VisualisationHelper.swift
//  Player
//
//  Created by Boris Bondarenko on 7/28/17.
//  Copyright © 2017 Applikey Solutions. All rights reserved.
//

import Foundation
import AudioKit
import AudioKitUI

class VisualisationHelper {
    
    private let avgFilterDepth = 8
    private let waveScale: Float = 1.9
    private let smoothWindow = 25
    private let smoothPassesCount = 5
    
    private var leftBuffer = [Float]()
    private var rightBuffer = [Float]()
    
    private var leftAvgFilter: AVGFilter!
    private var rightAvgFilter: AVGFilter!
    
    private init() { }
    
    // MARK: Shared Instance
    
    static let shared = VisualisationHelper()

    
    func updateWaveWithBuffer(_ buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32, leftWave: EZAudioPlot, rightWave: EZAudioPlot) {
        let sz = Int(bufferSize)
        reallocateBuffersIfNeeded(sz: sz)
        
        guard numberOfChannels > 0 else {
            return
        }
        
        
        let leftInputBuffer = buffer[0]!
        let leftOutputBuffer = UnsafeMutablePointer(mutating: leftBuffer)
        
        for _ in (0..<smoothPassesCount) {
            smooth(input: leftInputBuffer, output: leftOutputBuffer, n: sz, window: smoothWindow)
            bufCopy(input: leftOutputBuffer, output: leftInputBuffer, n: sz)
        }
        
        leftAvgFilter.addLine(data: leftInputBuffer)
        bufCopy(input: leftAvgFilter.resultUnsafePointer, output: leftOutputBuffer, n: sz)
        
        bufScale(buffer: leftOutputBuffer, n: sz, scale: waveScale)
        
        leftWave.updateBuffer((leftOutputBuffer + smoothWindow/2), withBufferSize: bufferSize - UInt32(smoothWindow))
        
        guard numberOfChannels > 1 else {
            return
        }
        
        let rightInputBuffer = buffer[1]!
        let rightOutputBuffer = UnsafeMutablePointer(mutating: rightBuffer)
        
        for _ in (0..<smoothPassesCount) {
            smooth(input: rightInputBuffer, output: rightOutputBuffer, n: sz, window: smoothWindow)
            bufCopy(input: rightOutputBuffer, output: rightInputBuffer, n: sz)
        }
        
        rightAvgFilter.addLine(data: rightInputBuffer)
        bufCopy(input: rightAvgFilter.resultUnsafePointer, output: rightOutputBuffer, n: sz)
        
        bufScale(buffer: rightOutputBuffer, n: sz, scale: waveScale)
        rightWave.updateBuffer((rightOutputBuffer + smoothWindow/2), withBufferSize: bufferSize - UInt32(smoothWindow))
    }
    
    private func reallocateBuffersIfNeeded(sz: Int) {
        guard leftBuffer.count < sz else {
            return
        }
        leftBuffer = [Float](repeating: 0.0, count: sz)
        rightBuffer = [Float](repeating: 0.0, count: sz)
        rightAvgFilter = AVGFilter(depth: avgFilterDepth, width: sz)
        leftAvgFilter = AVGFilter(depth: avgFilterDepth, width: sz)
        
    }
    
    private func bufScale(buffer: UnsafeMutablePointer<Float>,
                          n: Int, scale: Float) {
        for i in (0..<n) {
            buffer[i] = buffer[i] * scale
        }
    }
    
    private func bufCopy(input: UnsafeMutablePointer<Float>,
                         output: UnsafeMutablePointer<Float>,
                         n: Int) {
        for i in (0..<n) {
            output[i] = input[i]
        }
    }
    
    private func smooth(input: UnsafeMutablePointer<Float>,
                        output: UnsafeMutablePointer<Float>,
                        n: Int,
                        window aWindow: Int) {
        var k1 = 0
        var k2 = 0
        var hw = 0
        var tmp: Float = 0.0
        var window = aWindow
        
        if(fmod(Double(window),2) == 0) {
            window += 1
        }
        hw = (window - 1) / 2
        
        for i in (0...hw - 1) {
            output[i] = input[i] * 0.5
        }
        
        for i in (n - 1 - hw..<n) {
            output[i] = input[i] * 0.5
        }
        
        for i in (hw..<n - hw) {
            tmp = 0
            k1 = i - hw
            k2 = i + hw
            
            for j in (k1...k2) {
                tmp = tmp + input[j]
            }
            output[i] = tmp / Float(window)
        }
    }
}

private class AVGFilter {
    
    var resultUnsafePointer: UnsafeMutablePointer<Float> {
        return UnsafeMutablePointer(mutating: result)
    }
    
    private (set) var result: Array<Float>!
    private (set) var depth: Int
    private (set) var width: Int
    
    private var sumArr: Array<Float>!
    private var spinner = 0
    private var history: Array<Array<Float>>!
    
    init(depth aDepth: Int, width aWidth: Int) {
        assert(aDepth > 1)
        assert(aWidth > 1)
        depth = aDepth
        width = aWidth
        let arr = [Float](repeating: 0.0, count: width)
        result = arr
        sumArr = arr
        history = Array<Array<Float>> (repeating: arr, count: depth)
    }
    
    func addLine(data: UnsafeMutablePointer<Float>) {
        for i in (0..<width) {
            let oldVal = history[spinner][i]
            let newVal = data[i]
            history[spinner][i] = data[i]
            let newSum = sumArr[i] - oldVal + newVal
            sumArr[i] = newSum
            result[i] = newSum / Float(depth)
        }
        
        spinner += 1
        if spinner >= depth {
            spinner = 0
        }
    }
}
