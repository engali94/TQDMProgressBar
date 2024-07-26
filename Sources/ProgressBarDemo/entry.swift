import Foundation
import TQDMProgressBar

struct ProgressBarDemo {
    
    static func testProgressBarWithSequence() {
        let numbers = Array(1...10)
        let progressBar = ProgressBar(sequence: numbers, desc: "Processing sequence")
        for number in progressBar.iterate(numbers) {
            // Simulate work
            Thread.sleep(forTimeInterval: 0.1)
        }
    }

    static func testProgressBarWithTotal() {
        let total = 10
        let progressBar = ProgressBar(total: total, desc: "Processing total")
        for _ in 0..<total {
            // Simulate work
            Thread.sleep(forTimeInterval: 0.2)
            progressBar.update(1)
        }
        progressBar.close()
    }

    static func testProgressBarWithoutTotal() {
        let progressBar = ProgressBar(desc: "Processing unknown items")
        for i in 1...10 {
            // Simulate work
            Thread.sleep(forTimeInterval: 0.1)
            progressBar.update(1)
        }
        progressBar.close()
    }

    static func testProgressBarWithDescriptionChange() {
        let total = 10
        let progressBar = ProgressBar(total: total, desc: "Initial Description")
        for i in 0..<total {
            // Simulate work
            Thread.sleep(forTimeInterval: 0.1)
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
        for i in 0..<total {
            // Simulate work
            Thread.sleep(forTimeInterval: 0.1)
            progressBar.setPostfix("\(i * 10)% complete")
            progressBar.update(1)
        }
        progressBar.close()
    }

    static func testProgressBarAsync() async {
        let total = 10
        let progressBar = ProgressBar(total: total, desc: "Processing async")
        for _ in 0..<total {
            // Simulate async work
            if #available(macOS 10.15, *) {
                try? await Task.sleep(nanoseconds: 200_000_000)
            } else {
                // Fallback on earlier versions
            }
            progressBar.update(1)
        }
        progressBar.close()
    }

    static func main() async {
        testProgressBarWithSequence()
        testProgressBarWithTotal()
        testProgressBarWithoutTotal()
        testProgressBarWithDescriptionChange()
        testProgressBarWithPostfixChange()
        await testProgressBarAsync()
        print("All tests completed.")
    }
}

// This will run the `main` function
@main
struct ProgressBarDemoMain {
    static func main() {
        await ProgressBarDemo.main()
    }
}
