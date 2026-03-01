// The MIT License (MIT)
//
// Copyright (c) 2015-2026 Alexander Grebenyuk (github.com/kean).

import Testing
import Foundation
@testable import Nuke

@Suite struct ImagePipelineFormatsTests {
    let dataLoader: MockDataLoader
    let pipeline: ImagePipeline

    init() {
        let dataLoader = MockDataLoader()
        self.dataLoader = dataLoader
        self.pipeline = ImagePipeline {
            $0.dataLoader = dataLoader
            $0.imageCache = nil
        }
    }

    @Test func extendedColorSpaceSupport() async throws {
        // Given
        dataLoader.results[Test.url] = .success(
            (Test.data(name: "image-p3", extension: "jpg"), URLResponse(url: Test.url, mimeType: "jpeg", expectedContentLength: 20, textEncodingName: nil))
        )

        // When
        let response = try await pipeline.imageTask(with: Test.request).response

        // Then
        let image = response.image
        let cgImage = try #require(image.cgImage)
        let colorSpace = try #require(cgImage.colorSpace)
#if os(iOS) || os(tvOS) || os(macOS) || os(visionOS)
        #expect(colorSpace.isWideGamutRGB)
#elseif os(watchOS)
        #expect(!colorSpace.isWideGamutRGB)
#endif
    }

    @Test func grayscaleSupport() async throws {
        // Given
        dataLoader.results[Test.url] = .success(
            (Test.data(name: "grayscale", extension: "jpeg"), URLResponse(url: Test.url, mimeType: "jpeg", expectedContentLength: 20, textEncodingName: nil))
        )

        // When
        let response = try await pipeline.imageTask(with: Test.request).response

        // Then
        let image = response.image
        let cgImage = try #require(image.cgImage)
        #expect(cgImage.bitsPerComponent == 8)
    }
}
