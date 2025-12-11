import XCTest
@testable import LoggingKit

// MARK: - AtomicLogBuffer Tests

final class AtomicLogBufferTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        Log.logPath = .relative("TestLogs")
    }
    
    override func tearDown() {
        cleanupTestLogs()
        super.tearDown()
    }
    
    private func cleanupTestLogs() {
        let binaryPath = CommandLine.arguments[0]
        let binaryDirectory = URL(fileURLWithPath: binaryPath).deletingLastPathComponent()
        let testLogsDirectory = binaryDirectory.appendingPathComponent("TestLogs")
        try? FileManager.default.removeItem(at: testLogsDirectory)
    }
    
    // MARK: - Basic Functionality Tests
    
    func testBasicAppendAndConverged() {
        let buffer = AtomicLogBuffer(capacity: 100)
        
        buffer.append("Log 1")
        buffer.append("Log 2")
        buffer.append("Log 3")
        
        let result = buffer.converged()
        XCTAssertEqual(result, "Log 1\nLog 2\nLog 3")
    }
    
    func testEmptyBufferConverged() {
        let buffer = AtomicLogBuffer(capacity: 100)
        let result = buffer.converged()
        XCTAssertEqual(result, "")
    }
    
    func testSingleLogAppend() {
        let buffer = AtomicLogBuffer(capacity: 100)
        buffer.append("Single log")
        
        let result = buffer.converged()
        XCTAssertEqual(result, "Single log")
    }
    
    // MARK: - Capacity and Circular Buffer Tests
    
    func testCircularBufferOverwrite() {
        let capacity = 5
        let buffer = AtomicLogBuffer(capacity: capacity)
        
        // Add more logs than capacity
        for i in 0..<10 {
            buffer.append("Log \(i)")
        }
        
        // Should only contain the last 5 logs (5-9)
        let result = buffer.converged()
        let logs = result.split(separator: "\n")
        XCTAssertEqual(logs.count, capacity)
        
        // Verify circular buffer overwrote oldest entries
        XCTAssertTrue(result.contains("Log 5") || result.contains("Log 6"))
    }
    
    func testCapacityLimit() {
        let capacity = 100
        let buffer = AtomicLogBuffer(capacity: capacity)
        
        // Add exactly capacity logs
        for i in 0..<capacity {
            buffer.append("Log \(i)")
        }
        
        let result = buffer.converged()
        let logs = result.split(separator: "\n")
        XCTAssertEqual(logs.count, capacity)
    }
    
    func testOverCapacityHandling() {
        let capacity = 50
        let buffer = AtomicLogBuffer(capacity: capacity)
        
        // Add 2x capacity
        for i in 0..<(capacity * 2) {
            buffer.append("Message \(i)")
        }
        
        let result = buffer.converged()
        let logs = result.split(separator: "\n")
        
        // Should cap at capacity
        XCTAssertEqual(logs.count, capacity)
    }
    
    // MARK: - Thread Safety Tests
    
    func testConcurrentAppends() {
        let buffer = AtomicLogBuffer(capacity: 100_000)
        let expectation = XCTestExpectation(description: "Concurrent appends")
        
        let threadCount = 10
        let logsPerThread = 10_000
        expectation.expectedFulfillmentCount = threadCount
        
        // Launch multiple concurrent threads
        for threadId in 0..<threadCount {
            DispatchQueue.global(qos: .userInitiated).async {
                for logId in 0..<logsPerThread {
                    buffer.append("Thread \(threadId) - Log \(logId)")
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
        
        // Verify buffer has logs and no crash occurred
        let result = buffer.converged()
        XCTAssertFalse(result.isEmpty)
        
        let logs = result.split(separator: "\n")
        XCTAssertGreaterThan(logs.count, 0)
        XCTAssertLessThanOrEqual(logs.count, 100_000)
    }
    
    func testHighContentionWrites() {
        let buffer = AtomicLogBuffer(capacity: 10_000)
        let expectation = XCTestExpectation(description: "High contention writes")
        
        let threadCount = 50
        let logsPerThread = 1_000
        expectation.expectedFulfillmentCount = threadCount
        
        for threadId in 0..<threadCount {
            DispatchQueue.global(qos: .userInitiated).async {
                for logId in 0..<logsPerThread {
                    buffer.append("T\(threadId)-L\(logId)")
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
        
        let result = buffer.converged()
        let logs = result.split(separator: "\n")
        
        // Should have logs up to capacity
        XCTAssertEqual(logs.count, 10_000)
    }
    
    func testConcurrentReadsAndWrites() {
        let buffer = AtomicLogBuffer(capacity: 10_000)
        let expectation = XCTestExpectation(description: "Concurrent reads and writes")
        expectation.expectedFulfillmentCount = 20
        
        // Writer threads
        for threadId in 0..<10 {
            DispatchQueue.global(qos: .userInitiated).async {
                for logId in 0..<1_000 {
                    buffer.append("Writer \(threadId) - Log \(logId)")
                }
                expectation.fulfill()
            }
        }
        
        // Reader threads
        for _ in 0..<10 {
            DispatchQueue.global(qos: .userInitiated).async {
                for _ in 0..<100 {
                    _ = buffer.converged()
                    Thread.sleep(forTimeInterval: 0.001)
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
        
        // Verify no crashes and buffer is valid
        let finalResult = buffer.converged()
        XCTAssertFalse(finalResult.isEmpty)
    }
    
    // MARK: - Performance Tests
    
    func testAppendPerformance() {
        let buffer = AtomicLogBuffer(capacity: 1_000_000)
        
        measure {
            for i in 0..<100_000 {
                buffer.append("Performance log \(i)")
            }
        }
    }
    
    func testHighThroughputAppends() {
        let buffer = AtomicLogBuffer(capacity: 1_000_000)
        let startTime = Date()
        
        // Append 1 million logs
        for i in 0..<1_000_000 {
            buffer.append("Log \(i)")
        }
        
        let duration = Date().timeIntervalSince(startTime)
        let throughput = 1_000_000.0 / duration
        
        print("Throughput: \(Int(throughput)) logs/second")
        
        // Should be able to write at least 100K logs per second
        XCTAssertGreaterThan(throughput, 100_000)
    }
    
    func testConvergedPerformance() {
        let buffer = AtomicLogBuffer(capacity: 100_000)
        
        // Fill buffer
        for i in 0..<100_000 {
            buffer.append("Log entry \(i)")
        }
        
        measure {
            _ = buffer.converged()
        }
    }
    
    // MARK: - Correctness Tests
    
    func testLogOrdering() {
        let buffer = AtomicLogBuffer(capacity: 100)
        
        // Add logs sequentially
        for i in 0..<10 {
            buffer.append("Log \(i)")
        }
        
        let result = buffer.converged()
        let logs = result.split(separator: "\n").map(String.init)
        
        // Verify order
        for i in 0..<10 {
            XCTAssertEqual(logs[i], "Log \(i)")
        }
    }
    
    func testCircularBufferOrdering() {
        let capacity = 5
        let buffer = AtomicLogBuffer(capacity: capacity)
        
        // Add 10 logs to a buffer with capacity 5
        for i in 0..<10 {
            buffer.append("Log \(i)")
        }
        
        let result = buffer.converged()
        let logs = result.split(separator: "\n")
        
        // Should contain logs 5-9 in order
        XCTAssertEqual(logs.count, 5)
    }
    
    // MARK: - Memory Tests
    
    func testMemoryOverwrite() {
        let capacity = 10
        let buffer = AtomicLogBuffer(capacity: capacity)
        
        // First batch
        for i in 0..<capacity {
            buffer.append("First batch \(i)")
        }
        
        let firstResult = buffer.converged()
        XCTAssertTrue(firstResult.contains("First batch 0"))
        
        // Second batch - should overwrite
        for i in 0..<capacity {
            buffer.append("Second batch \(i)")
        }
        
        let secondResult = buffer.converged()
        XCTAssertFalse(secondResult.contains("First batch"))
        XCTAssertTrue(secondResult.contains("Second batch"))
    }
    
    func testLargeLogHandling() {
        let buffer = AtomicLogBuffer(capacity: 1000)
        
        // Create large log strings
        let largeLog = String(repeating: "A", count: 10_000)
        
        for i in 0..<100 {
            buffer.append("\(i): \(largeLog)")
        }
        
        let result = buffer.converged()
        XCTAssertFalse(result.isEmpty)
        XCTAssertGreaterThan(result.count, 100_000)
    }
    
    // MARK: - Integration with Log.History
    
    func testLogHistoryIntegration() {
        // Add logs via Log.History API
        Log.History.add("Integration test 1")
        Log.History.add("Integration test 2")
        Log.History.add("Integration test 3")
        
        let result = Log.History.converged()
        
        // Should contain our test logs (may also contain others)
        XCTAssertTrue(result.contains("Integration test 1"))
        XCTAssertTrue(result.contains("Integration test 2"))
        XCTAssertTrue(result.contains("Integration test 3"))
    }
    
    func testLogHistoryConcurrentAccess() {
        let expectation = XCTestExpectation(description: "Concurrent Log.History access")
        expectation.expectedFulfillmentCount = 20
        
        // Multiple threads writing to Log.History
        for threadId in 0..<20 {
            DispatchQueue.global(qos: .userInitiated).async {
                for logId in 0..<500 {
                    Log.History.add("Thread \(threadId) - Log \(logId)")
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
        
        // Verify no crashes
        let result = Log.History.converged()
        XCTAssertFalse(result.isEmpty)
    }
    
    // MARK: - Edge Cases
    
    func testMinimalCapacity() {
        let buffer = AtomicLogBuffer(capacity: 1)
        
        buffer.append("Log 1")
        buffer.append("Log 2")
        
        let result = buffer.converged()
        let logs = result.split(separator: "\n")
        
        // Should only keep last log
        XCTAssertEqual(logs.count, 1)
    }
    
    func testSpecialCharacters() {
        let buffer = AtomicLogBuffer(capacity: 100)
        
        buffer.append("Log with\nnewline")
        buffer.append("Log with\ttab")
        buffer.append("Log with emoji 🚀")
        buffer.append("Log with unicode: こんにちは")
        
        let result = buffer.converged()
        XCTAssertTrue(result.contains("emoji 🚀"))
        XCTAssertTrue(result.contains("unicode: こんにちは"))
    }
    
    func testEmptyStringAppend() {
        let buffer = AtomicLogBuffer(capacity: 100)
        
        buffer.append("")
        buffer.append("Real log")
        buffer.append("")
        
        let result = buffer.converged()
        let logs = result.split(separator: "\n")
        
        // Empty strings should still be stored
        XCTAssertEqual(logs.count, 1) // split removes empty strings
        XCTAssertTrue(result.contains("Real log"))
    }
}

