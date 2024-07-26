import Foundation

/// A progress bar that can iterate over a sequence or display progress for a given total.
///
/// Example usage:
/// ```swift
/// // Iterating over a sequence
/// let numbers = Array(1...100)
/// let progressBar = ProgressBar(desc: "Processing")
/// for number in progressBar.iterate(numbers) {
///     // Process each number
///     Thread.sleep(forTimeInterval: 0.1)
///     progressBar.update(1)
/// }
///
/// // Using with a known total
/// let total = 50
/// let bar = ProgressBar(total: total, desc: "Downloading")
/// for _ in 0..<total {
///     // Simulate work
///     Thread.sleep(forTimeInterval: 0.2)
///     bar.update(1)
/// }
/// bar.close()
/// ```
public class ProgressBar {
    private var total: Int?
    private var n: Int = 0
    private var lastPrintN: Int = 0
    private let minIntervalSeconds: TimeInterval = 0.1
    private let maxIntervalSeconds: TimeInterval = 10.0
    private var lastPrintTime: Date = Date()
    private var width: Int = 40
    private let unitScale: Double
    private let unitDivisor: Double
    private var avgTime: Double?
    private var startTime: Date
    private var lastIterTime: Date?
    private var desc: String
    private var postfix: String = ""
    private var iterator: AnyIterator<Any>?
    private var isFirstYield = true
    private var style: ProgressBarStyle
    
    /// Initializes a new ProgressBar instance with a known total.
    ///
    /// - Parameters:
    ///   - total: The total number of items.
    ///   - desc: A description of the progress bar.
    ///   - style: The style of the progress bar.
    ///
    /// Example:
    /// ```swift
    /// let bar = ProgressBar(total: 100, desc: "Processing")
    /// for i in 0..<100 {
    ///     // Do some work
    ///     Thread.sleep(forTimeInterval: 0.1)
    ///     bar.update(1)
    /// }
    /// bar.close()
    /// ```
    public init(total: Int, desc: String = "", style: ProgressBarStyle = .default) {
        self.total = total
        self.desc = desc
        self.style = style
        self.unitScale = style.unitScale
        self.unitDivisor = style.unitDivisor
        self.startTime = Date()
        self.width = style.ncols ?? 40
    }
    
    /// Initializes a new ProgressBar instance with a sequence.
    ///
    /// - Parameters:
    ///   - sequence: The sequence to iterate over.
    ///   - desc: A description of the progress bar.
    ///   - style: The style of the progress bar.
    ///
    /// Example:
    /// ```swift
    /// let items = Array(1...100)
    /// let bar = ProgressBar(sequence: items, desc: "Processing items")
    /// for item in bar.iterate(items) {
    ///     // Process item
    ///     Thread.sleep(forTimeInterval: 0.1)
    /// }
    /// ```
    public init<T: Sequence>(sequence: T, desc: String = "", style: ProgressBarStyle = .default) {
        self.total = (sequence as? (any Collection))?.count
        self.desc = desc
        self.style = style
        self.unitScale = style.unitScale
        self.unitDivisor = style.unitDivisor
        self.startTime = Date()
        self.width = style.ncols ?? 40
        
        var iterator = sequence.makeIterator()
        self.iterator = AnyIterator { iterator.next() as Any }
    }
    
    /// Initializes a new ProgressBar instance without a known total.
    ///
    /// - Parameters:
    ///   - total: The total number of items. If nil, the progress bar will not show percentage.
    ///   - desc: A description of the progress bar.
    ///   - style: The style of the progress bar.
    ///
    /// Example:
    /// ```swift
    /// let bar = ProgressBar(desc: "Processing unknown items")
    /// while let item = getNextItem() {
    ///     // Process item
    ///     Thread.sleep(forTimeInterval: 0.1)
    ///     bar.update(1)
    /// }
    /// bar.close()
    /// ```
    public init(total: Int? = nil, desc: String = "", style: ProgressBarStyle = .default) {
        self.total = total
        self.desc = desc
        self.style = style
        self.unitScale = style.unitScale
        self.unitDivisor = style.unitDivisor
        self.startTime = Date()
        self.width = style.ncols ?? 40
    }
    
    /// Iterates over a sequence, updating the progress bar for each item.
    ///
    /// - Parameter sequence: The sequence to iterate over.
    /// - Returns: An `AnySequence` that can be iterated over.
    ///
    /// Example:
    /// ```swift
    /// let numbers = Array(1...100)
    /// let bar = ProgressBar(total: numbers.count, desc: "Processing numbers")
    /// for number in bar.iterate(numbers) {
    ///     // Process number
    ///     Thread.sleep(forTimeInterval: 0.1)
    /// }
    /// ```
    public func iterate<T: Sequence>(_ sequence: T) -> AnySequence<T.Element> {
        return AnySequence { AnyIterator {
            if let next = self.iterator?.next() as? T.Element {
                self.update(1)
                return next
            } else {
                self.close()
                return nil
            }
        }}
    }
    
    private func next() -> Any? {
        if let next = self.iterator?.next() {
            self.update(1)
            return next
        } else {
            self.close()
            return nil
        }
    }
    
    /// Updates the progress bar.
    ///
    /// - Parameter n: The number of steps to advance the progress bar.
    ///
    /// Example:
    /// ```swift
    /// let bar = ProgressBar(total: 100, desc: "Downloading")
    /// for _ in 0..<100 {
    ///     // Download chunk
    ///     Thread.sleep(forTimeInterval: 0.1)
    ///     bar.update(1)
    /// }
    /// bar.close()
    /// ```
    public func update(_ n: Int = 1) {
        self.n += n
        if shouldPrint() {
            printProgress()
            lastPrintN = self.n
            lastPrintTime = Date()
        }
    }
    
    /// Resets the progress bar.
    ///
    /// - Parameter total: The new total number of items. If nil, the original total is used.
    ///
    /// Example:
    /// ```swift
    /// let bar = ProgressBar(total: 50, desc: "Processing")
    /// // ... do some work ...
    /// bar.reset(total: 100) // Reset with a new total
    /// // ... continue processing ...
    /// ```
    public func reset(total: Int? = nil) {
        n = 0
        lastPrintN = 0
        lastPrintTime = Date()
        startTime = Date()
        if let total = total {
            self.total = total
        }
        printProgress()
    }
    
    /// Closes the progress bar and moves to the next line.
    ///
    /// Example:
    /// ```swift
    /// let bar = ProgressBar(total: 100, desc: "Processing")
    /// for _ in 0..<100 {
    ///     // Do work
    ///     Thread.sleep(forTimeInterval: 0.1)
    ///     bar.update(1)
    /// }
    /// bar.close()
    /// ```
    public func close() {
        if n != lastPrintN {
            printProgress()
        }
        print() // Move to next line
    }
    
    /// Sets a new description for the progress bar.
    ///
    /// - Parameter desc: The new description.
    ///
    /// Example:
    /// ```swift
    /// let bar = ProgressBar(total: 100, desc: "Downloading")
    /// // ... start downloading ...
    /// bar.setDescription("Processing downloaded data")
    /// // ... process data ...
    /// ```
    public func setDescription(_ desc: String) {
        self.desc = desc
        printProgress()
    }
    
    /// Sets a new postfix for the progress bar.
    ///
    /// - Parameter postfix: The new postfix.
    ///
    /// Example:
    /// ```swift
    /// let bar = ProgressBar(total: 100, desc: "Uploading")
    /// for i in 0..<100 {
    ///     // Upload chunk
    ///     Thread.sleep(forTimeInterval: 0.1)
    ///     bar.update(1)
    ///     bar.setPostfix("\(i)% complete")
    /// }
    /// ```
    public func setPostfix(_ postfix: String) {
        self.postfix = postfix
        printProgress()
    }
    
    private func shouldPrint() -> Bool {
        let now = Date()
        let timeSinceLastPrint = now.timeIntervalSince(lastPrintTime)
        return timeSinceLastPrint >= minIntervalSeconds ||
            (total != nil && Double(self.n - lastPrintN) / Double(total!) >= 0.01) ||
            timeSinceLastPrint >= maxIntervalSeconds
    }
    
    private func printProgress() {
        let now = Date()
        let elapsedSeconds = now.timeIntervalSince(startTime)
        
        var values: [String: String] = [:]
        
        // Percentage
        if let total = total {
            let percentage = min(100.0, max(0.0, Double(n) / Double(total) * 100.0))
            values["percentage"] = String(format: "%3.0f%%", percentage)
        } else {
            values["percentage"] = "    "
        }
        
        // Progress bar
        if let total = total {
            let filledLength = Int(Double(width) * Double(n) / Double(total))
            let bar = String(repeating: style.fill, count: filledLength) + String(repeating: style.emptyFill, count: width - filledLength)
            values["bar"] = "\(style.leftBracket)\(bar)\(style.rightBracket)"
        } else {
            values["bar"] = ""
        }
        
        // Counters and Unit
        let unit = style.unitScale == 1.0 && style.unitDivisor == 1.0 ? "" : "it"
        values["n_fmt"] = formatNumber(Double(n) * style.unitScale / style.unitDivisor)
        values["total_fmt"] = total.map { formatNumber(Double($0) * style.unitScale / style.unitDivisor) } ?? "?"
        values["unit"] = unit
        
        // Rate
        if elapsedSeconds > 0 {
            let rate = Double(n) / elapsedSeconds
            let scaledRate = rate * style.unitScale / style.unitDivisor
            let unitSuffix = unit.isEmpty ? "it" : unit
            values["rate_fmt"] = String(format: "%.2f %@/s", scaledRate, unitSuffix)
        } else {
            values["rate_fmt"] = "? it/s"
        }
        
        // Elapsed time
        values["elapsed"] = formatInterval(elapsedSeconds)
        
        // Remaining time
        if let total = total, n > 0 {
            let remainingSeconds = elapsedSeconds * Double(total - n) / Double(n)
            values["remaining"] = formatInterval(remainingSeconds)
        } else {
            values["remaining"] = "?"
        }
        
        // Description and postfix
        values["desc"] = desc
        values["postfix"] = postfix
        
        // Left bar (everything to the left of the progress bar)
        values["l_bar"] = "\(values["desc"]!) \(values["percentage"]!)\(style.barSeparator)"
        
        var output = style.barFormat.format
        for (key, value) in values {
            output = output.replacingOccurrences(of: "{\(key)}", with: value)
        }
        
        // Apply bar color
        if let barColor = style.barColor {
            let coloredBar = barColor.rawValue + values["bar"]! + ProgressBarStyle.Color.reset.rawValue
            output = output.replacingOccurrences(of: values["bar"]!, with: coloredBar)
        }
        
        // Apply description color
        if let descColor = style.descColor {
            let coloredDesc = descColor.rawValue + values["desc"]! + ProgressBarStyle.Color.reset.rawValue
            output = output.replacingOccurrences(of: values["desc"]!, with: coloredDesc)
        }
        
        print("\r\(output)", terminator: "")
        fflush(stdout)
    }

    
    private func formatInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private func formatNumber(_ n: Double) -> String {
        if n >= 1_000_000_000 {
            return String(format: "%.1fB", n / 1_000_000_000)
        } else if n >= 1_000_000 {
            return String(format: "%.1fM", n / 1_000_000)
        } else if n >= 1_000 {
            return String(format: "%.1fK", n / 1_000)
        } else {
            return String(format: "%.1f", n)
        }
    }
}

extension ProgressBar {
    
    
    /// Creates a progress bar for a range of numbers.
    ///
    /// - Parameters:
    ///   - start: The start of the range.
    ///   - end: The end of the range.
    ///   - step: The step size.
    /// - Returns: A ProgressBar instance.
    ///
    /// Example:
    /// ```swift
    /// let bar = ProgressBar(start: 0, end: 100, step: 2)
    /// for i in stride(from: 0, to: 100, by: 2) {
    ///     // Process i
    ///     Thread.sleep(forTimeInterval: 0.1)
    ///     bar.update(1)
    /// }
    /// ```
    public convenience init(start: Int, end: Int, step: Int = 1) {
        let total: Int
        if step != 0 {
            total = max(0, (end - start + step - 1) / step)
        } else {
            total = 0
        }
        self.init(total: total)
    }
    
    /// Creates a progress bar for a sequence.
    ///
    /// - Parameters:
    ///   - sequence: The sequence to iterate over.
    ///   - desc: A description of the progress bar.
    ///   - style: The style of the progress bar.
    /// - Returns: An `AnySequence` that can be iterated over with a progress bar.
    ///
    /// Example:
    /// ```swift
    /// let numbers = Array(1...100)
    /// for number in ProgressBar.tqdm(numbers, desc: "Processing numbers") {
    ///     // Process number
    ///     Thread.sleep(forTimeInterval: 0.1)
    /// }
    /// ```
    public static func tqdm<T: Sequence>(_ sequence: T, desc: String = "", style: ProgressBarStyle = .default) -> AnySequence<T.Element> {
        let total = (sequence as? (any Collection))?.count ?? 0
        let bar = ProgressBar(total: total, desc: desc, style: style)
        return bar.iterate(sequence)
    }
}

extension ProgressBar {
    
    /// Creates a progress bar that executes a closure for each iteration.
    ///
    /// - Parameter closure: The closure to be executed for each iteration.
    ///
    /// Example:
    /// ```swift
    /// let bar = ProgressBar(total: 50, desc: "Processing")
    /// bar.forEach {
    ///     // Do some work
    ///     Thread.sleep(forTimeInterval: 0.1)
    /// }
    /// ```
    public func forEach(_ closure: () -> Void) {
        while self.n < self.total! {
            closure()
            self.update(1)
        }
        self.close()
    }
    
    /// Creates a progress bar that executes an async closure for each iteration.
    ///
    /// - Parameter closure: The async closure to be executed for each iteration.
    ///
    /// Example:
    /// ```swift
    /// let bar = ProgressBar(total: 50, desc: "Fetching data")
    /// try await bar.forEach {
    ///     try await fetchDataFromServer()
    /// }
    /// ```
    public func forEach(_ closure: () async throws -> Void) async throws {
        while self.n < self.total! {
            try await closure()
            self.update(1)
        }
        self.close()
    }
    
    /// Creates a progress bar for an async sequence.
    ///
    /// - Parameters:
    ///   - sequence: The async sequence to iterate over.
    ///   - total: The total number of items in the sequence, if known.
    ///   - desc: A description of the progress bar.
    /// - Returns: An async stream that wraps the original sequence with a progress bar.
    ///
    /// Example:
    /// ```swift
    /// let asyncItems = AsyncStream { continuation in
    ///     for i in 1...100 {
    ///         continuation.yield(i)
    ///         Thread.sleep(forTimeInterval: 0.1)
    ///     }
    ///     continuation.finish()
    /// }
    ///
    /// for try await item in ProgressBar.stream(asyncItems, desc: "Processing") {
    ///     // Process item
    /// }
    /// ```
    @available(macOS 10.15, iOS 13.0, *)
    public static func stream<S: AsyncSequence>(_ sequence: S, total: Int? = nil, desc: String = "") -> AsyncThrowingStream<S.Element, Error> {
        let inferredTotal: Int?
        if let total = total {
            inferredTotal = total
        } else if let collection = sequence as? any Collection {
            inferredTotal = collection.count
        } else {
            inferredTotal = nil
        }
        
        let progressBar = ProgressBar(total: inferredTotal, desc: desc)
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await element in sequence {
                        progressBar.update(1)
                        continuation.yield(element)
                    }
                    progressBar.close()
                    continuation.finish()
                } catch {
                    progressBar.close()
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    /// Tracks the progress of an asynchronous operation.
    ///
    /// - Parameters:
    ///   - polling: The interval at which to update the progress bar.
    ///   - operation: The asynchronous operation to track.
    /// - Returns: The result of the operation.
    ///
    /// Example:
    /// ```swift
    /// let bar = ProgressBar(desc: "Downloading")
    /// let result = try await bar.track(with: 1.0) {
    ///     try await downloadLargeFile()
    /// }
    /// print("Download complete, result: \(result)")
    /// ```
    @available(macOS 13.0, iOS 13.0, *)
    public func track<U>(with polling: TimeInterval = 1,_ operation: @escaping () async throws -> U) async throws -> U {
        return try await withThrowingTaskGroup(of: U?.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                while !Task.isCancelled {
                    await MainActor.run {
                        self.update(1)
                    }
                    try await Task.sleep(for: .seconds(polling))
                }
                return nil
            }
            
            var result: U?
            for try await taskResult in group {
                if let nonNilResult = taskResult {
                    result = nonNilResult
                    group.cancelAll()
                    break
                }
            }
            
            await MainActor.run {
                self.close()
            }
            
            guard let finalResult = result else {
                throw CancellationError()
            }
            
            return finalResult
        }
    }
}
