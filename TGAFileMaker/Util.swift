//
//  Util.swift
//  TGAFileMaker
//
//  Created by Gabriel Thomson on 8/5/26.
//

import Foundation

import Metal
import CoreImage
internal import UniformTypeIdentifiers
import AppKit
import SwiftUI

func mtlTextureToFile(_ texture: MTLTexture) -> PNGDocument? {
    if let data = textureToPNGData(texture) {
        return PNGDocument(data: data)
    } else {
        return nil
    }
}

func textureToPNGData(_ texture: MTLTexture) -> Data? {
    // Optional: ensure the texture is CPU-readable
    // (if storageMode == .private you must blit to a .shared/.managed texture first)
    
    let options: [CIImageOption: Any] = [
        .colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
    ]
    
    guard var ciImage = CIImage(mtlTexture: texture, options: options) else {
        return nil
    }
    
    // Flip vertically (Metal origin is bottom-left)
    ciImage = ciImage.oriented(.downMirrored)
    // Equivalent transform:
    // let transform = CGAffineTransform(scaleX: 1, y: -1)
    //     .translatedBy(x: 0, y: -ciImage.extent.height)
    // ciImage = ciImage.transformed(by: transform)
    
    let context = CIContext(options: nil)
    
    guard let cgImage = context.createCGImage(
        ciImage,
        from: ciImage.extent,
        format: .RGBA8,
        colorSpace: CGColorSpace(name: CGColorSpace.sRGB)
    ) else {
        return nil
    }
    let rep = NSBitmapImageRep(cgImage: cgImage)
    return rep.representation(using: .png, properties: [:])
}

struct PNGDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.png] }
    
    let data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
