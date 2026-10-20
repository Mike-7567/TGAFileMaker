//
//  ContentView.swift
//  TGAFileMaker
//
//  Created by Gabriel Thomson on 8/5/26.
//

import SwiftUI
internal import UniformTypeIdentifiers
import MetalKit

struct ContentView: View {
    @State private var isShowingRoughnessFileImporter: Bool = false
    @State private var isShowingEmissiveFileImporter: Bool = false
    @State private var isShowingMetalnessFileImporter: Bool = false
    @State private var isShowingOutputFileExporter: Bool = false
    
    @State private var roughness: MTLTexture?
    @State private var emissive: MTLTexture?
    @State private var metalness: MTLTexture?
    @State private var output: MTLTexture?
    @State private var outputDoc: PNGDocument?
    
    var body: some View {
        VStack {
            HStack {
                Button("Roughness file - blue") {
                    isShowingRoughnessFileImporter.toggle()
                }
                .fileImporter(isPresented: $isShowingRoughnessFileImporter, allowedContentTypes: [.png]) { result in
                    switch result {
                    case .success(let url):
                        if (!url.startAccessingSecurityScopedResource()) { return }
                        
                        roughness = try? TEXTURE_LOADER.newTexture(URL: url, options: [.SRGB: false])
                        
                        url.stopAccessingSecurityScopedResource()
                        
                        let descriptor = MTLTextureDescriptor()
                        descriptor.pixelFormat = roughness!.pixelFormat
                        descriptor.width = roughness!.width
                        descriptor.height = roughness!.height
                        descriptor.usage = [.shaderRead, .shaderWrite]
                        
                        output = DEVICE?.makeTexture(descriptor: descriptor)
                    case .failure(let error):
                        print(error)
                    }
                }
                Button("Emissive file - green") {
                    isShowingEmissiveFileImporter.toggle()
                }
                .fileImporter(isPresented: $isShowingEmissiveFileImporter, allowedContentTypes: [.png]) { result in
                    switch result {
                    case .success(let url):
                        if (!url.startAccessingSecurityScopedResource()) { return }
                        
                        emissive = try? TEXTURE_LOADER.newTexture(URL: url, options: [.SRGB: false])
                        
                        url.stopAccessingSecurityScopedResource()
                    case .failure(let error):
                        print(error)
                    }
                }
                Button("Metalness file - red") {
                    isShowingMetalnessFileImporter.toggle()
                }
                .fileImporter(isPresented: $isShowingMetalnessFileImporter, allowedContentTypes: [.png]) { result in
                    switch result {
                    case .success(let url):
                        if (!url.startAccessingSecurityScopedResource()) { return }
                        
                        metalness = try? TEXTURE_LOADER.newTexture(URL: url, options: [.SRGB: false])
                        
                        url.stopAccessingSecurityScopedResource()
                    case .failure(let error):
                        print(error)
                    }
                }
            }.padding()
            
            Button("Create tga") {
                guard let metalness, let emissive, let roughness else {
                    print("Missing one or more textures")
                    return
                }
                guard roughness.height == metalness.height, metalness.height == emissive.height else {
                    print("Texture heights do not match")
                    return
                }
                guard roughness.width == metalness.width, metalness.width == emissive.width else {
                    print("Texture widths do not match")
                    return
                }
                guard let buffer = COMMAND_QUEUE?.makeCommandBuffer() else {
                    print("Failed to make buffer")
                    return
                }
                
                guard let computeCommandEncoder = buffer.makeComputeCommandEncoder() else {
                    print("Failed to make command encoder")
                    return
                }
                
                computeCommandEncoder.setComputePipelineState(COMBINE_PIPELINE!)
                computeCommandEncoder.setTexture(roughness, index: 0)
                computeCommandEncoder.setTexture(emissive, index: 1)
                computeCommandEncoder.setTexture(metalness, index: 2)
                computeCommandEncoder.setTexture(output, index: 3)
                computeCommandEncoder.dispatchThreadgroups(MTLSize(width: roughness.width, height: roughness.height, depth: 1), threadsPerThreadgroup: MTLSize(width: 1, height: 1, depth: 1))
                computeCommandEncoder.endEncoding()
                
                buffer.commit()
                
                buffer.waitUntilCompleted()
                
                
                
                guard let outputDoc = mtlTextureToFile(output!) else {
                    print("Failed to create PNG file")
                    return;
                }
                
                isShowingOutputFileExporter = true
            }.fileExporter(isPresented: $isShowingOutputFileExporter, document: outputDoc, contentTypes: [.png], defaultFilename: "_mers") { result in
                switch result {
                case .success(let url):
                    print("Saved to \(url)")
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

//#Preview {
//    ContentView()
//}
