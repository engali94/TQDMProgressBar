import Foundation
import TQDMProgressBar

enum ProgressBarDemo {
    static func sleep(interval: TimeInterval) {
        Thread.sleep(forTimeInterval: interval)
    }

    static func testProgressBarWithSequence() {
        let numbers = Array(1 ... 10)
        let progressBar = ProgressBar(sequence: numbers, desc: "Processing sequence")
        for _ in progressBar.iterate(numbers) {
            Thread.sleep(forTimeInterval: 0.5)
        }
    }

    static func testProgressBarWithTotal() {
        let total = 10
        let progressBar = ProgressBar(total: total, desc: "Processing total")
        for _ in 0 ..< total {
            Thread.sleep(forTimeInterval: 0.5)
            progressBar.update(1)
        }
        progressBar.close()
    }

    static func testProgressBarWithoutTotal() {
        let progressBar = ProgressBar(desc: "Processing unknown items")
        for _ in 1 ... 10 {
            Thread.sleep(forTimeInterval: 0.5)
            progressBar.update(1)
        }
        progressBar.close()
    }

    static func testProgressBarWithDescriptionChange() {
        let total = 10
        let progressBar = ProgressBar(total: total, desc: "Initial Description")
        for i in 0 ..< total {
            Thread.sleep(forTimeInterval: 0.5)
            if i == 5 {
                progressBar.setDescription("Updated Description")
            }
            progressBar.update(1)
        }
        progressBar.close()
    }

    static func testProgressBarWithPostfixChange() {
        let total = 10
        let progressBar = ProgressBar(total: total, desc: "Processing with postfix")
        for i in 0 ..< total {
            Thread.sleep(forTimeInterval: 0.5)
            progressBar.setPostfix("\(i * 10)% complete")
            progressBar.update(1)
        }
        progressBar.close()
    }

    static func testProgressBarAsync() async {
        let total = 10
        let progressBar = ProgressBar(total: total, desc: "Processing async")
        for _ in 0 ..< total {
            if #available(macOS 10.15, *) {
                try? await Task.sleep(nanoseconds: 500_000_000)
            } else {
                // Fallback on earlier versions
            }
            progressBar.update(1)
        }
        progressBar.close()
    }

    static func testProgressBarStyles() {
        let styles: [(String, ProgressBarStyle)] = [
            ("Default", .default),
            ("ASCII", ProgressBarStyle(leftBracket: "[", rightBracket: "]", emptyFill: "-", fill: "#")),
            ("Circle", ProgressBarStyle(leftBracket: "", rightBracket: "", emptyFill: "○", fill: "●")),
            ("Arrow", ProgressBarStyle(leftBracket: "", rightBracket: "", emptyFill: "─", fill: "►")),
            ("Braille", ProgressBarStyle(leftBracket: "⡄", rightBracket: "⢀", emptyFill: "⣀", fill: "⣿")),
            ("Custom", ProgressBarStyle(leftBracket: "【", rightBracket: "】", emptyFill: " ", fill: "=")),
        ]

        for (styleName, style) in styles {
            print("\nTesting \(styleName) style:")
            let total = 50
            let progressBar = ProgressBar(total: total, desc: "Processing", style: style)
            for _ in 0 ..< total {
                Thread.sleep(forTimeInterval: 0.04)
                progressBar.update(1)
            }
            progressBar.close()
        }
    }

    static func testProgressBarFormats() {
        let formats: [(String, ProgressBarStyle.BarFormat)] = [
            ("Standard", .standard),
            ("Simple", .simple),
            ("Custom", .custom("{l_bar}{bar}| {percentage:3.0f}% - {n_fmt}/{total_fmt}")),
        ]

        for (formatName, format) in formats {
            print("\nTesting \(formatName) format:")
            let style = ProgressBarStyle(barFormat: format)
            let total = 50
            let progressBar = ProgressBar(total: total, desc: "Processing", style: style)
            for _ in 0 ..< total {
                Thread.sleep(forTimeInterval: 0.02)
                progressBar.update(1)
            }
            progressBar.close()
        }
    }

    static func testProgressBarColors() {
        print("\nTesting color styles:")
        let colors: [(String, ProgressBarStyle.Color)] = [
            ("Red", .red),
            ("Green", .green),
            ("Yellow", .yellow),
            ("Blue", .blue),
            ("Magenta", .magenta),
            ("Cyan", .cyan),
            ("White", .white),
        ]

        for (colorName, color) in colors {
            var style = ProgressBarStyle.default
            style.barColor = color
            style.descColor = color
            let total = 30
            let progressBar = ProgressBar(total: total, desc: "\(colorName) bar", style: style)
            for _ in 0 ..< total {
                Thread.sleep(forTimeInterval: 0.05)
                progressBar.update(1)
            }
            progressBar.close()
        }
    }

    static func testNarrowProgressBar() {
        print("\nTesting narrow progress bar:")
        var style = ProgressBarStyle.default
        style.ncols = 20
        let total = 30
        let progressBar = ProgressBar(total: total, desc: "Narrow", style: style)
        for _ in 0 ..< total {
            Thread.sleep(forTimeInterval: 0.5)
            progressBar.update(1)
        }
        progressBar.close()
    }

    static func testUnitScaleAndDivisor() {
        print("\nTesting unit scale and divisor:")
        var style = ProgressBarStyle.default
        style.unitScale = 1024.0
        style.unitDivisor = 1024.0
        let total = 100
        let progressBar = ProgressBar(total: total, desc: "Download", style: style)
        for _ in 0 ..< total {
            Thread.sleep(forTimeInterval: 0.1)
            progressBar.update(1)
        }
        progressBar.close()
    }

    @available(macOS 10.15, iOS 13.0, *)
    static func testProgressBarStream() async throws {
        print("\nTesting ProgressBar.stream:")

        let asyncSequence = AsyncStream { continuation in
            Task {
                for i in 1 ... 50 {
                    continuation.yield(i)
                    try await Task.sleep(nanoseconds: 5_000_000)
                }
                continuation.finish()
            }
        }

        let stream = ProgressBar.stream(asyncSequence, total: .max, desc: "Streaming")
        for try await _ in stream {
            // No need to sleep here as the AsyncStream already has delays
        }
    }

    static func testProgressBarForEach() {
        print("\nTesting ProgressBar forEach:")
        let progressBar = ProgressBar(total: 30, desc: "ForEach")
        for item in progressBar {
            Thread.sleep(forTimeInterval: 0.1)
        }
    }

    @available(macOS 10.15, iOS 13.0, *)
    static func testProgressBarForEachAsync() async throws {
        print("\nTesting ProgressBar forEach async:")
        let progressBar = ProgressBar(total: 30, desc: "ForEach Async")
        try await progressBar.forEach {
            try await Task.sleep(nanoseconds: 100_000_000)
        }
    }

    @available(macOS 13.0, iOS 13.0, *)
    static func testProgressBarTrack() async throws {
        print("\nTesting ProgressBar track:")
        let progressBar = ProgressBar(total: 100, desc: "Tracking")
        let result = try await progressBar.track(with: 0.2) { () -> Int in
            var sum = 0
            for i in 1 ... 100 {
                sum += i
                try await Task.sleep(nanoseconds: 200_000_000)
            }
            return sum
        }
        print("Track result: \(result)")
    }

    static func main() async throws {
//        testProgressBarWithSequence()
//        print("\n")
        testProgressBarWithTotal()
        print("\n")
        testProgressBarWithoutTotal()
        print("\n")
        testProgressBarWithDescriptionChange()
        print("\n")
        testProgressBarWithPostfixChange()
        print("\n")
        await testProgressBarAsync()
        print("\n")
        testProgressBarStyles()
        print("\n")
        testProgressBarFormats()
        print("\n")
        testProgressBarColors()
        print("\n")
        testNarrowProgressBar()
        print("\n")
        testUnitScaleAndDivisor()
        print("\n")

        if #available(macOS 10.15, iOS 13.0, *) {
            try await testProgressBarStream()
            print("\n")
            try await testProgressBarForEachAsync()
            print("\n")
        }
        testProgressBarForEach()
        print("\n")

        if #available(macOS 13.0, iOS 13.0, *) {
            try await testProgressBarTrack()
            print("\n")
        }

        print("All tests completed.")
    }
}

@main
struct ProgressBarDemoMain {
    static func main() async {
        do {
            try await ProgressBarDemo.main()
        } catch {}
    }
}
