// The MIT License (MIT)
//
// Copyright (c) 2015-2026 Alexander Grebenyuk (github.com/kean).

import Testing
import Foundation
@testable import Nuke

#if !os(macOS)
import UIKit
#endif

@Suite struct ImagePipelineProcessorTests {
    let pipeline: ImagePipeline

    init() {
        let dataLoader = MockDataLoader()
        self.pipeline = ImagePipeline {
            $0.dataLoader = dataLoader
            $0.imageCache = nil
        }
    }

    // MARK: - Applying Filters

    @Test func thatImageIsProcessed() async throws {
        // Given
        let request = ImageRequest(url: Test.url, processors: [MockImageProcessor(id: "processor1")])

        // When
        let response = try await pipeline.imageTask(with: request).response

        // Then
        #expect(response.image.nk_test_processorIDs == ["processor1"])
    }

    // MARK: - Composing Filters

    @Test func applyingMultipleProcessors() async throws {
        // Given
        let request = ImageRequest(
            url: Test.url,
            processors: [
                MockImageProcessor(id: "processor1"),
                MockImageProcessor(id: "processor2")
            ]
        )

        // When
        let response = try await pipeline.imageTask(with: request).response

        // Then
        #expect(response.image.nk_test_processorIDs == ["processor1", "processor2"])
    }

    @Test func performingRequestWithoutProcessors() async throws {
        // Given
        let request = ImageRequest(url: Test.url, processors: [])

        // When
        let response = try await pipeline.imageTask(with: request).response

        // Then
        #expect(response.image.nk_test_processorIDs == [])
    }

    // MARK: - Decompression

#if !os(macOS)
    @Test func decompressionSkippedIfProcessorsAreApplied() async throws {
        // Given
        let request = ImageRequest(url: Test.url, processors: [ImageProcessors.Anonymous(id: "1", { image in
            #expect(ImageDecompression.isDecompressionNeeded(for: image) == true)
            return image
        })])

        // When/Then
        _ = try await pipeline.image(for: request)
    }
#endif
}
