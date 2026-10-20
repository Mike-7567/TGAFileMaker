//
//  MetalConstants.swift
//  TGAFileMaker
//
//  Created by Gabriel Thomson on 8/5/26.
//

import Foundation
import Metal
import MetalKit

let DEVICE = MTLCreateSystemDefaultDevice()
let TEXTURE_LOADER = MTKTextureLoader(device: DEVICE!)
let COMMAND_QUEUE = DEVICE!.makeCommandQueue()
let LIBRARY = DEVICE!.makeDefaultLibrary()

var COMBINE_PIPELINE: MTLComputePipelineState?

func makePipeLines() {
    let PIPELINE_DESCRIPTOR = MTLComputePipelineDescriptor()
    PIPELINE_DESCRIPTOR.computeFunction = LIBRARY?.makeFunction(name: "combineTextures")
    PIPELINE_DESCRIPTOR.label = "Combine Textures"
    
    COMBINE_PIPELINE = try! DEVICE?.makeComputePipelineState(descriptor: PIPELINE_DESCRIPTOR, options: []).0
}
