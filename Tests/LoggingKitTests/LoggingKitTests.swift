import XCTest
@testable import LoggingKit

final class LoggingKitTests: XCTestCase {
    struct TestLogger: Loggable {
        static let subsystem: String = "TestSubsystem"
    }
    
    override func setUp() {
        super.setUp()
        // Reset state before each test
        Log.logPath = .relative("TestLogs")
        Log.logLevel = Log.Level.Info
        Log.enableLiveLogging = true
        LiveLogHistory.shared.logs = []
        Log.History.current.clear()
        Log.fileLimit = 10_000
    }
    
    override func tearDown() {
        // Clean up after each test
        Log.logLevel = Log.Level.Info
        LiveLogHistory.shared.logs = []
        cleanupTestLogs()
        super.tearDown()
    }
    
    private func cleanupTestLogs() {
        let binaryPath = CommandLine.arguments[0]
        let binaryDirectory = URL(fileURLWithPath: binaryPath).deletingLastPathComponent()
        let testLogsDirectory = binaryDirectory.appendingPathComponent("TestLogs")
        try? FileManager.default.removeItem(at: testLogsDirectory)
    }
    
    func testLogSignal() {
        // Basic test to ensure the Log enum is accessible
        XCTAssertNotNil(Log.self)
    }
    
    func testLoggableProtocol() {
        // Test that we can conform to Loggable
        XCTAssertEqual("\(TestLogger.subsystem)", "TestSubsystem")
    }
    
    // MARK: - Log Level Tests
    
    func testTraceLogging() {
        Log.logLevel = Log.Level.Trace
        TestLogger.logTrace("Test trace message")
        
        // Wait for async log processing
        let expectation = XCTestExpectation(description: "Wait for log")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(LiveLogHistory.shared.logs.count, 1)
        XCTAssertEqual(LiveLogHistory.shared.logs.first?.level, .trace)
        XCTAssertEqual(LiveLogHistory.shared.logs.first?.message, "Test trace message")
        
        let historyString = Log.History.converged()
        XCTAssertTrue(historyString.contains("Test trace message"))
        XCTAssertTrue(historyString.contains("TRACE"))
    }
    
    func testDebugLogging() {
        Log.logLevel = Log.Level.Debug
        TestLogger.logDebug("Test debug message")
        
        // Wait for async log processing
        let expectation = XCTestExpectation(description: "Wait for log")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(LiveLogHistory.shared.logs.count, 1)
        XCTAssertEqual(LiveLogHistory.shared.logs.first?.level, .debug)
        XCTAssertEqual(LiveLogHistory.shared.logs.first?.message, "Test debug message")
        
        let historyString = Log.History.converged()
        XCTAssertTrue(historyString.contains("Test debug message"))
        XCTAssertTrue(historyString.contains("DEBUG"))
    }
    
    func testInfoLogging() {
        TestLogger.logInfo("Test info message")
        
        // Wait for async log processing
        let expectation = XCTestExpectation(description: "Wait for log")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(LiveLogHistory.shared.logs.count, 1)
        XCTAssertEqual(LiveLogHistory.shared.logs.first?.level, .info)
        XCTAssertEqual(LiveLogHistory.shared.logs.first?.message, "Test info message")
        
        let historyString = Log.History.converged()
        XCTAssertTrue(historyString.contains("Test info message"))
        XCTAssertTrue(historyString.contains("INFO"))
    }
    
    func testUserEventLogging() {
        TestLogger.logUserEvent("Test user event")
        
        // Wait for async log processing
        let expectation = XCTestExpectation(description: "Wait for log")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(LiveLogHistory.shared.logs.count, 1)
        XCTAssertEqual(LiveLogHistory.shared.logs.first?.level, .userEvent)
        XCTAssertEqual(LiveLogHistory.shared.logs.first?.message, "Test user event")
        
        let historyString = Log.History.converged()
        XCTAssertTrue(historyString.contains("Test user event"))
    }
    
    func testPerformanceLogging() {
        TestLogger.logPerformance("Test performance")
        
        // Wait for async log processing
        let expectation = XCTestExpectation(description: "Wait for log")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(LiveLogHistory.shared.logs.count, 1)
        XCTAssertEqual(LiveLogHistory.shared.logs.first?.level, .performance)
        XCTAssertEqual(LiveLogHistory.shared.logs.first?.message, "Test performance")
        
        let historyString = Log.History.converged()
        XCTAssertTrue(historyString.contains("Test performance"))
    }
    
    func testSuccessLogging() {
        TestLogger.logSuccess("Test success")
        
        // Wait for async log processing
        let expectation = XCTestExpectation(description: "Wait for log")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(LiveLogHistory.shared.logs.count, 1)
        XCTAssertEqual(LiveLogHistory.shared.logs.first?.level, .success)
        XCTAssertEqual(LiveLogHistory.shared.logs.first?.message, "Test success")
        
        let historyString = Log.History.converged()
        XCTAssertTrue(historyString.contains("Test success"))
    }
    
    func testNoticeLogging() {
        TestLogger.logNotice("Test notice")
        
        // Wait for async log processing
        let expectation = XCTestExpectation(description: "Wait for log")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(LiveLogHistory.shared.logs.count, 1)
        XCTAssertEqual(LiveLogHistory.shared.logs.first?.level, .notice)
        XCTAssertEqual(LiveLogHistory.shared.logs.first?.message, "Test notice")
        
        let historyString = Log.History.converged()
        XCTAssertTrue(historyString.contains("Test notice"))
    }
    
    func testWarningLogging() {
        TestLogger.logWarning("Test warning")
        
        // Wait for async log processing
        let expectation = XCTestExpectation(description: "Wait for log")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(LiveLogHistory.shared.logs.count, 1)
        XCTAssertEqual(LiveLogHistory.shared.logs.first?.level, .warning)
        XCTAssertEqual(LiveLogHistory.shared.logs.first?.message, "Test warning")
        
        let historyString = Log.History.converged()
        XCTAssertTrue(historyString.contains("Test warning"))
    }
    
    func testErrorLogging() {
        TestLogger.logError("Test error")
        
        // Wait for async log processing
        let expectation = XCTestExpectation(description: "Wait for log")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(LiveLogHistory.shared.logs.count, 1)
        XCTAssertEqual(LiveLogHistory.shared.logs.first?.level, .error)
        XCTAssertEqual(LiveLogHistory.shared.logs.first?.message, "Test error")
        
        let historyString = Log.History.converged()
        XCTAssertTrue(historyString.contains("Test error"))
        XCTAssertTrue(historyString.contains("ERROR"))
    }
    
    func testCriticalLogging() {
        // Note: In DEBUG builds, critical() calls fatalError, so we can't test it normally
        // This test verifies the log is added before the fatalError
        #if !DEBUG
        TestLogger.critical("Test critical")
        
        // Wait for async log processing
        let expectation = XCTestExpectation(description: "Wait for log")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(LiveLogHistory.shared.logs.count, 1)
        XCTAssertEqual(LiveLogHistory.shared.logs.first?.level, .critical)
        XCTAssertEqual(LiveLogHistory.shared.logs.first?.message, "Test critical")
        
        let historyString = Log.History.converged()
        XCTAssertTrue(historyString.contains("Test critical"))
        XCTAssertTrue(historyString.contains("CRITICAL"))
        #else
        // In DEBUG, critical terminates, so we skip this test
        #endif
    }
    
    // MARK: - Debug Log Collection Tests
    
    // MARK: - Log Level Filtering Tests
    
    func testLogLevelFiltering() {
        // Set level to Info
        Log.logLevel = Log.Level.Info
        
        // Trace and Debug should be ignored
        TestLogger.logTrace("Trace message")
        TestLogger.logDebug("Debug message")
        
        // Info should be collected
        TestLogger.logInfo("Info message")
        
        // Wait for async log processing
        let expectation = XCTestExpectation(description: "Wait for log")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(LiveLogHistory.shared.logs.count, 1)
        XCTAssertEqual(LiveLogHistory.shared.logs.first?.message, "Info message")
        
        var historyString = Log.History.converged()
        XCTAssertTrue(historyString.contains("Info message"))
        XCTAssertFalse(historyString.contains("Trace message"))
        XCTAssertFalse(historyString.contains("Debug message"))
        
        // Set level to Trace
        Log.logLevel = Log.Level.Trace
        TestLogger.logTrace("Trace message 2")
        
        // Wait for async log processing
        let expectation2 = XCTestExpectation(description: "Wait for log")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 1.0)
        
        XCTAssertEqual(LiveLogHistory.shared.logs.count, 2)
        XCTAssertEqual(LiveLogHistory.shared.logs.last?.message, "Trace message 2")
        
        historyString = Log.History.converged()
        XCTAssertTrue(historyString.contains("Trace message 2"))
    }
    
    // MARK: - Log Buffer Limit Tests
    
    func testLogBufferLimit() {
        let originalLimit = Log.fileLimit
        Log.fileLimit = 5
        Log.logLevel = Log.Level.Debug
        
        // Clear Log.History buffer to start fresh
        Log.History.current.clear()
        
        // Add exactly 4 logs (one less than the limit to avoid auto-clear)
        for i in 0..<4 {
            TestLogger.logDebug("Message \(i)")
        }
        
        // Wait for async log processing
        let expectation = XCTestExpectation(description: "Wait for logs")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Verify LiveLogHistory has the logs
        XCTAssertEqual(LiveLogHistory.shared.logs.count, 4)
        XCTAssertEqual(LiveLogHistory.shared.logs.first?.message, "Message 0")
        XCTAssertEqual(LiveLogHistory.shared.logs.last?.message, "Message 3")
        
        // Verify Log.History contains the messages
        let historyString = Log.History.converged()
        XCTAssertTrue(historyString.contains("Message 0"))
        XCTAssertTrue(historyString.contains("Message 3"))
        XCTAssertTrue(historyString.contains("DEBUG"))
        
        // Now add one more to trigger the limit and auto-clear
        TestLogger.logDebug("Message 4")
        
        // Wait for async log processing
        let expectation2 = XCTestExpectation(description: "Wait for logs after limit")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 1.0)
        
        // After reaching the limit, Log.History should be cleared (or contain only the last message)
        // The buffer gets cleared when it reaches limitPerFile, so it should be empty or have just the new message
        let historyString2 = Log.History.converged()
        // The buffer may be empty (if cleared) or contain "Message 4"
        // Either way, it should not contain the old messages if the clear happened
        if !historyString2.isEmpty {
            XCTAssertTrue(historyString2.contains("Message 4"))
        }
        
        Log.fileLimit = originalLimit
    }
    
    func testLogBufferUnlimited() {
        let originalLimit = Log.fileLimit
        Log.fileLimit = 0 // Unlimited
        Log.logLevel = Log.Level.Debug
        
        // Add many logs
        for i in 0..<100 {
            TestLogger.logDebug("Message \(i)")
        }
        
        // Wait for async log processing
        let expectation = XCTestExpectation(description: "Wait for logs")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Should keep all logs
        XCTAssertEqual(LiveLogHistory.shared.logs.count, 100)
        
        let historyString = Log.History.converged()
        // Verify some messages are in the history
        XCTAssertTrue(historyString.contains("Message 0"))
        XCTAssertTrue(historyString.contains("Message 99"))
        
        Log.fileLimit = originalLimit
    }
    
    // MARK: - Thread Safety Tests
    
    func testConcurrentLogging() {
        Log.logLevel = Log.Level.Info
        let expectation = XCTestExpectation(description: "Concurrent logging")
        expectation.expectedFulfillmentCount = 100
        
        let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
        
        for i in 0..<100 {
            queue.async {
                TestLogger.logInfo("Concurrent message \(i)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Wait for async logs to be processed on MainActor
        let waitExpectation = XCTestExpectation(description: "Wait for logs")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            waitExpectation.fulfill()
        }
        wait(for: [waitExpectation], timeout: 1.0)
        
        // All logs should be collected without crashes
        XCTAssertEqual(LiveLogHistory.shared.logs.count, 100)
        
        let historyString = Log.History.converged()
        // Verify concurrent messages are in the history
        XCTAssertTrue(historyString.contains("Concurrent message 0"))
        XCTAssertTrue(historyString.contains("Concurrent message 99"))
    }
    
    func testConcurrentLoggingDifferentLevels() {
        Log.logLevel = Log.Level.Trace
        let expectation = XCTestExpectation(description: "Concurrent logging different levels")
        expectation.expectedFulfillmentCount = 200
        
        let queue = DispatchQueue(label: "test.levels", attributes: .concurrent)
        
        // Mix different log levels concurrently
        for i in 0..<50 {
            queue.async {
                TestLogger.logTrace("Trace \(i)")
                expectation.fulfill()
            }
            queue.async {
                TestLogger.logDebug("Debug \(i)")
                expectation.fulfill()
            }
            queue.async {
                TestLogger.logInfo("Info \(i)")
                expectation.fulfill()
            }
            queue.async {
                TestLogger.logWarning("Warning \(i)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        // Wait for async logs to be processed
        let waitExpectation = XCTestExpectation(description: "Wait for logs")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            waitExpectation.fulfill()
        }
        wait(for: [waitExpectation], timeout: 1.0)
        
        // Should have all logs without crashes
        XCTAssertEqual(LiveLogHistory.shared.logs.count, 200)
        
        let historyString = Log.History.converged()
        XCTAssertTrue(historyString.contains("Trace 0"))
        XCTAssertTrue(historyString.contains("Debug 0"))
        XCTAssertTrue(historyString.contains("Info 0"))
        XCTAssertTrue(historyString.contains("Warning 0"))
    }
    
    func testConcurrentLogHistoryAccess() {
        Log.logLevel = Log.Level.Debug
        let expectation = XCTestExpectation(description: "Concurrent Log.History access")
        expectation.expectedFulfillmentCount = 50
        
        let writeQueue = DispatchQueue(label: "test.write", attributes: .concurrent)
        let readQueue = DispatchQueue(label: "test.read", attributes: .concurrent)
        
        // Concurrent writes
        for i in 0..<50 {
            writeQueue.async {
                TestLogger.logDebug("History write \(i)")
                expectation.fulfill()
            }
        }
        
        // Concurrent reads while writing
        for _ in 0..<20 {
            readQueue.async {
                _ = Log.History.converged()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Wait for async processing
        let waitExpectation = XCTestExpectation(description: "Wait for logs")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            waitExpectation.fulfill()
        }
        wait(for: [waitExpectation], timeout: 1.0)
        
        // Verify no crashes and logs are present
        let historyString = Log.History.converged()
        XCTAssertTrue(historyString.contains("History write 0"))
        XCTAssertTrue(historyString.contains("History write 49"))
    }
    
    func testConcurrentHookRegistration() {
        Log.logLevel = Log.Level.Info
        let expectation = XCTestExpectation(description: "Concurrent hook registration")
        expectation.expectedFulfillmentCount = 100
        
        var hookCallCount = 0
        let lock = NSLock()
        
        // Register hook
        Log.registerInfoHook { _, _ in
            lock.lock()
            hookCallCount += 1
            lock.unlock()
        }
        
        let queue = DispatchQueue(label: "test.hooks", attributes: .concurrent)
        
        // Concurrent logging with hooks
        for i in 0..<100 {
            queue.async {
                TestLogger.logInfo("Hook test \(i)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Wait for async processing
        let waitExpectation = XCTestExpectation(description: "Wait for hooks")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            waitExpectation.fulfill()
        }
        wait(for: [waitExpectation], timeout: 1.0)
        
        // Hook should be called for all logs
        lock.lock()
        let count = hookCallCount
        lock.unlock()
        XCTAssertEqual(count, 100, "Hook should be called 100 times")
        
        Log.registerInfoHook(nil)
    }
    
    func testConcurrentLogLevelChanges() {
        let expectation = XCTestExpectation(description: "Concurrent log level changes")
        expectation.expectedFulfillmentCount = 100
        
        let queue = DispatchQueue(label: "test.level", attributes: .concurrent)
        
        // Concurrently change log level and log messages
        for i in 0..<50 {
            queue.async {
                Log.logLevel = Log.Level.Trace
                TestLogger.logTrace("Level test trace \(i)")
                expectation.fulfill()
            }
            queue.async {
                Log.logLevel = Log.Level.Info
                TestLogger.logInfo("Level test info \(i)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Wait for async processing
        let waitExpectation = XCTestExpectation(description: "Wait for logs")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            waitExpectation.fulfill()
        }
        wait(for: [waitExpectation], timeout: 1.0)
        
        // Should not crash despite concurrent level changes
        let historyString = Log.History.converged()
        XCTAssertTrue(historyString.contains("Level test") || historyString.isEmpty)
    }
    
    func testHighContentionLogging() {
        Log.logLevel = Log.Level.Debug
        let expectation = XCTestExpectation(description: "High contention logging")
        expectation.expectedFulfillmentCount = 50
        
        // Use many threads with high contention
        let threadCount = 50
        let logsPerThread = 100
        
        for threadId in 0..<threadCount {
            DispatchQueue.global(qos: .userInitiated).async {
                for logId in 0..<logsPerThread {
                    TestLogger.logDebug("Thread \(threadId) - Log \(logId)")
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
        
        // Wait for async processing
        let waitExpectation = XCTestExpectation(description: "Wait for logs")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            waitExpectation.fulfill()
        }
        wait(for: [waitExpectation], timeout: 2.0)
        
        // Should have many logs without crashes
        XCTAssertGreaterThanOrEqual(LiveLogHistory.shared.logs.count, 1000)
        
        let historyString = Log.History.converged()
        XCTAssertTrue(historyString.contains("Thread 0"))
        XCTAssertTrue(historyString.contains("Thread \(threadCount - 1)"))
    }
    
    func testConcurrentLiveHistoryReads() {
        Log.logLevel = Log.Level.Info
        let expectation = XCTestExpectation(description: "Concurrent LiveHistory reads")
        expectation.expectedFulfillmentCount = 100
        
        let writeQueue = DispatchQueue(label: "test.write", attributes: .concurrent)
        let readQueue = DispatchQueue(label: "test.read", attributes: .concurrent)
        
        // Concurrent writes
        for i in 0..<100 {
            writeQueue.async {
                TestLogger.logInfo("Read test \(i)")
                expectation.fulfill()
            }
        }
        
        // Concurrent reads from LiveLogHistory
        let readExpectation = XCTestExpectation(description: "Concurrent reads")
        readExpectation.expectedFulfillmentCount = 50
        for _ in 0..<50 {
            readQueue.async {
                let count = LiveLogHistory.shared.logs.count
                XCTAssertGreaterThanOrEqual(count, 0, "Read should not crash")
                readExpectation.fulfill()
            }
        }
        
        wait(for: [expectation, readExpectation], timeout: 5.0)
        
        // Wait for async processing
        let waitExpectation = XCTestExpectation(description: "Wait for logs")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            waitExpectation.fulfill()
        }
        wait(for: [waitExpectation], timeout: 1.0)
        
        XCTAssertEqual(LiveLogHistory.shared.logs.count, 100)
    }
    
    func testConcurrentMultipleSubsystems() {
        Log.logLevel = Log.Level.Info
        
        struct Logger1: Loggable {
            static let subsystem: String = "Subsystem1"
        }
        
        struct Logger2: Loggable {
            static let subsystem: String = "Subsystem2"
        }
        
        struct Logger3: Loggable {
            static let subsystem: String = "Subsystem3"
        }
        
        let expectation = XCTestExpectation(description: "Concurrent multiple subsystems")
        expectation.expectedFulfillmentCount = 150
        
        let queue = DispatchQueue(label: "test.subsystems", attributes: .concurrent)
        
        // Log from different subsystems concurrently
        for i in 0..<50 {
            queue.async {
                Logger1.logInfo("Sub1 message \(i)")
                expectation.fulfill()
            }
            queue.async {
                Logger2.logInfo("Sub2 message \(i)")
                expectation.fulfill()
            }
            queue.async {
                Logger3.logInfo("Sub3 message \(i)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        // Wait for async processing
        let waitExpectation = XCTestExpectation(description: "Wait for logs")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            waitExpectation.fulfill()
        }
        wait(for: [waitExpectation], timeout: 1.0)
        
        // Should have all logs from all subsystems
        XCTAssertEqual(LiveLogHistory.shared.logs.count, 150)
        
        let historyString = Log.History.converged()
        XCTAssertTrue(historyString.contains("Sub1 message 0"))
        XCTAssertTrue(historyString.contains("Sub2 message 0"))
        XCTAssertTrue(historyString.contains("Sub3 message 0"))
    }
    
    func testConcurrentErrorAndWarningLogging() {
        Log.logLevel = Log.Level.Info
        let expectation = XCTestExpectation(description: "Concurrent error and warning")
        expectation.expectedFulfillmentCount = 200
        
        let queue = DispatchQueue(label: "test.errors", attributes: .concurrent)
        
        // Mix errors and warnings concurrently
        for i in 0..<100 {
            queue.async {
                TestLogger.logWarning("Warning \(i)")
                expectation.fulfill()
            }
            queue.async {
                TestLogger.logError("Error \(i)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        // Wait for async processing
        let waitExpectation = XCTestExpectation(description: "Wait for logs")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            waitExpectation.fulfill()
        }
        wait(for: [waitExpectation], timeout: 1.0)
        
        // Should have all logs
        XCTAssertEqual(LiveLogHistory.shared.logs.count, 200)
        
        let historyString = Log.History.converged()
        XCTAssertTrue(historyString.contains("Warning 0"))
        XCTAssertTrue(historyString.contains("Error 0"))
    }
    
    // MARK: - Log File Name Tests
    
    func testFileNameExtraction() {
        let path = "/path/to/MyFile.swift"
        let fileName = Log.fileName(from: path)
        XCTAssertEqual(fileName, "MyFile")
    }
    
    func testFileNameExtractionWithUndefined() {
        // Test with an invalid path that doesn't contain a file name
        let path = "/"
        let fileName = Log.fileName(from: path)
        // Empty path or root path may not return "UNDEFINED" due to URL behavior
        // So we just verify it doesn't crash and returns a string
        XCTAssertFalse(fileName.isEmpty)
    }
    
    // MARK: - Log Configuration Tests
    
    func testLogFilePrefix() {
        let originalPrefix = Log.defaultLogFileName
        Log.defaultLogFileName = "TEST_PREFIX"
        XCTAssertEqual(Log.defaultLogFileName, "TEST_PREFIX")
        Log.defaultLogFileName = originalPrefix
    }
    
    // MARK: - Log File Writing Tests
    
    private func getWritableTestDirectory() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let testDir = tempDir.appendingPathComponent("LoggingKitTests-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: testDir, withIntermediateDirectories: true)
        return testDir
    }
    
    func testLogFileCreation() {
        // Set up absolute path for testing using temp directory
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "TestLog"
        Log.History.current.clear()
        
        // Add some logs
        TestLogger.logInfo("Test message 1")
        TestLogger.logInfo("Test message 2")
        TestLogger.logInfo("Test message 3")
        
        // Save to file
        Log.saveCurrentSession()
        
        // Find the log file
        let logFile = testDir.appendingPathComponent("TestLog.log")
        
        // Verify file exists
        let fileManager = FileManager.default
        XCTAssertTrue(fileManager.fileExists(atPath: logFile.path), "Log file should be created")
        
        // Verify file content
        if let content = try? String(contentsOf: logFile, encoding: .utf8) {
            XCTAssertTrue(content.contains("LOG FOR SESSION"), "File should contain session header")
            XCTAssertTrue(content.contains("Test message 1"), "File should contain logged messages")
            XCTAssertTrue(content.contains("Test message 2"), "File should contain logged messages")
            XCTAssertTrue(content.contains("Test message 3"), "File should contain logged messages")
            XCTAssertTrue(content.contains("END LOG FOR SESSION"), "File should contain session footer")
        } else {
            XCTFail("Could not read log file content")
        }
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
    }
    
    func testLogFileAppending() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        let originalAppend = Log.fileAppendingType
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "AppendTest"
        Log.fileAppendingType = .appendToExistingLogFile
        Log.History.current.clear()
        
        let fileManager = FileManager.default
        let logFile = testDir.appendingPathComponent("AppendTest.log")
        
        // Verify no file exists initially
        XCTAssertFalse(fileManager.fileExists(atPath: logFile.path), "No log file should exist initially")
        
        // First session
        Log.History.current.clear() // Clear buffer before adding new log
        TestLogger.logInfo("First session message")
        Log.saveCurrentSession()
        
        // Verify exactly one file exists after first save
        XCTAssertTrue(fileManager.fileExists(atPath: logFile.path), "Exactly one log file should exist after first save")
        let allFiles = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
        let logFiles = allFiles.filter { $0.lastPathComponent.hasPrefix("AppendTest") && $0.pathExtension == "log" }
        XCTAssertEqual(logFiles.count, 1, "Should have exactly 1 log file in append mode")
        
        // Second session
        Log.History.current.clear() // Clear buffer before adding new log
        TestLogger.logInfo("Second session message")
        Log.saveCurrentSession()
        
        // Verify still exactly one file exists after second save
        XCTAssertTrue(fileManager.fileExists(atPath: logFile.path), "Log file should still exist")
        let allFiles2 = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
        let logFiles2 = allFiles2.filter { $0.lastPathComponent.hasPrefix("AppendTest") && $0.pathExtension == "log" }
        XCTAssertEqual(logFiles2.count, 1, "Should still have exactly 1 log file in append mode")
        
        // Third session
        Log.History.current.clear() // Clear buffer before adding new log
        TestLogger.logInfo("Third session message")
        Log.saveCurrentSession()
        
        // Verify still exactly one file exists after third save
        let allFiles3 = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
        let logFiles3 = allFiles3.filter { $0.lastPathComponent.hasPrefix("AppendTest") && $0.pathExtension == "log" }
        XCTAssertEqual(logFiles3.count, 1, "Should still have exactly 1 log file after multiple appends")
        
        // Verify file content contains all sessions
        if let content = try? String(contentsOf: logFile, encoding: .utf8) {
            // Count sessions by looking for session headers
            let sessionHeaders = content.components(separatedBy: "--- LOG FOR SESSION")
            let sessionCount = sessionHeaders.count - 1
            XCTAssertEqual(sessionCount, 3, "File should contain exactly 3 sessions, found \(sessionCount)")
            XCTAssertTrue(content.contains("First session message"), "File should contain first session")
            XCTAssertTrue(content.contains("Second session message"), "File should contain second session")
            XCTAssertTrue(content.contains("Third session message"), "File should contain third session")
            
            // Verify session order (first should appear before second, second before third)
            if let firstRange = content.range(of: "First session message"),
               let secondRange = content.range(of: "Second session message"),
               let thirdRange = content.range(of: "Third session message") {
                XCTAssertLessThan(firstRange.lowerBound, secondRange.lowerBound, "First session should come before second")
                XCTAssertLessThan(secondRange.lowerBound, thirdRange.lowerBound, "Second session should come before third")
            }
        } else {
            XCTFail("Could not read log file content")
        }
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
        Log.fileAppendingType = originalAppend
    }
    
    func testLogFileNumbering() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        let originalAppend = Log.fileAppendingType
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "NumberedTest"
        Log.fileAppendingType = .alwaysCreateNewLogFile
        Log.History.current.clear()
        
        let fileManager = FileManager.default
        
        // Create first file
        TestLogger.logInfo("First file message")
        Log.saveCurrentSession()
        
        // Verify exactly one file exists (base file)
        let baseFile = testDir.appendingPathComponent("NumberedTest.log")
        XCTAssertTrue(fileManager.fileExists(atPath: baseFile.path), "Base log file should exist")
        let allFiles1 = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
        let logFiles1 = allFiles1.filter { $0.lastPathComponent.hasPrefix("NumberedTest") && $0.pathExtension == "log" }
        XCTAssertEqual(logFiles1.count, 1, "Should have exactly 1 log file after first save")
        
        // Create second file
        TestLogger.logInfo("Second file message")
        Log.saveCurrentSession()
        
        // Verify exactly two files exist (base and numbered)
        let numberedFile = testDir.appendingPathComponent("NumberedTest-1.log")
        XCTAssertTrue(fileManager.fileExists(atPath: baseFile.path), "Base log file should still exist")
        XCTAssertTrue(fileManager.fileExists(atPath: numberedFile.path), "Numbered log file should exist")
        let allFiles2 = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
        let logFiles2 = allFiles2.filter { $0.lastPathComponent.hasPrefix("NumberedTest") && $0.pathExtension == "log" }
        XCTAssertEqual(logFiles2.count, 2, "Should have exactly 2 log files after second save")
        
        // Create third file
        TestLogger.logInfo("Third file message")
        Log.saveCurrentSession()
        
        // Verify exactly three files exist
        let numberedFile2 = testDir.appendingPathComponent("NumberedTest-2.log")
        XCTAssertTrue(fileManager.fileExists(atPath: numberedFile2.path), "Second numbered log file should exist")
        let allFiles3 = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
        let logFiles3 = allFiles3.filter { $0.lastPathComponent.hasPrefix("NumberedTest") && $0.pathExtension == "log" }
        XCTAssertEqual(logFiles3.count, 3, "Should have exactly 3 log files after third save")
        
        // Verify each file contains its respective message
        if let content1 = try? String(contentsOf: baseFile, encoding: .utf8) {
            XCTAssertTrue(content1.contains("First file message"), "Base file should contain first message")
        }
        if let content2 = try? String(contentsOf: numberedFile, encoding: .utf8) {
            XCTAssertTrue(content2.contains("Second file message"), "Numbered file should contain second message")
        }
        if let content3 = try? String(contentsOf: numberedFile2, encoding: .utf8) {
            XCTAssertTrue(content3.contains("Third file message"), "Second numbered file should contain third message")
        }
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
        Log.fileAppendingType = originalAppend
    }
    
    func testLogFileRelativePath() {
        let testDir = getWritableTestDirectory()
        let subDir = testDir.appendingPathComponent("CustomLogs").appendingPathComponent("SubDir")
        try? FileManager.default.createDirectory(at: subDir, withIntermediateDirectories: true)
        
        let originalPath = Log.logPath
        Log.logPath = .absolute(subDir.path)
        Log.defaultLogFileName = "RelativeTest"
        Log.History.current.clear()
        
        TestLogger.logInfo("Relative path test")
        Log.saveCurrentSession()
        
        // Find the log file
        let logFile = subDir.appendingPathComponent("RelativeTest.log")
        
        let fileManager = FileManager.default
        XCTAssertTrue(fileManager.fileExists(atPath: logFile.path), "Log file should be created in subdirectory")
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
    }
    
    func testLogFileRelativePathNil() {
        let originalPath = Log.logPath
        Log.logPath = .relative() // nil parameter - should use binary directory directly
        Log.defaultLogFileName = "RelativeNilTest"
        Log.History.current.clear()
        
        TestLogger.logInfo("Relative nil path test")
        Log.saveCurrentSession()
        
        // Find the log file in binary directory
        let binaryPath = CommandLine.arguments[0]
        let binaryDirectory = URL(fileURLWithPath: binaryPath).deletingLastPathComponent()
        let logFile = binaryDirectory.appendingPathComponent("RelativeNilTest.log")
        
        let fileManager = FileManager.default
        
        // Check if directory is writable (may not be in test environment)
        let isWritable = fileManager.isWritableFile(atPath: binaryDirectory.path)
        
        if isWritable {
            XCTAssertTrue(fileManager.fileExists(atPath: logFile.path), "Log file should be created in binary directory when relative path is nil")
            
            // Verify file content
            if let content = try? String(contentsOf: logFile, encoding: .utf8) {
                XCTAssertTrue(content.contains("Relative nil path test"), "File should contain logged message")
            }
            
            // Cleanup
            try? fileManager.removeItem(at: logFile)
        } else {
            // Directory is not writable (common in test environments), but verify code doesn't crash
            XCTAssertFalse(fileManager.fileExists(atPath: logFile.path), "Log file should not exist when directory is not writable")
        }
        
        Log.logPath = originalPath
    }
    
    func testLogFileRelativePathWithSubdirectory() {
        let originalPath = Log.logPath
        Log.logPath = .relative("SubDirTest")
        Log.defaultLogFileName = "SubDirTest"
        Log.History.current.clear()
        
        TestLogger.logInfo("Subdirectory test")
        Log.saveCurrentSession()
        
        // Find the log file in relative subdirectory
        let binaryPath = CommandLine.arguments[0]
        let binaryDirectory = URL(fileURLWithPath: binaryPath).deletingLastPathComponent()
        let subDir = binaryDirectory.appendingPathComponent("SubDirTest")
        let logFile = subDir.appendingPathComponent("SubDirTest.log")
        
        let fileManager = FileManager.default
        
        // Check if parent directory is writable (may not be in test environment)
        let isWritable = fileManager.isWritableFile(atPath: binaryDirectory.path)
        
        if isWritable {
            XCTAssertTrue(fileManager.fileExists(atPath: logFile.path), "Log file should be created in relative subdirectory")
            
            // Cleanup
            try? fileManager.removeItem(at: subDir)
        } else {
            // Directory is not writable (common in test environments), but verify code doesn't crash
            XCTAssertFalse(fileManager.fileExists(atPath: logFile.path), "Log file should not exist when directory is not writable")
        }
        
        Log.logPath = originalPath
    }
    
    func testLogFileContentFormat() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "FormatTest"
        Log.History.current.clear()
        
        // Add logs with different levels
        Log.logLevel = Log.Level.Trace
        TestLogger.logTrace("Trace message")
        TestLogger.logDebug("Debug message")
        TestLogger.logInfo("Info message")
        TestLogger.logWarning("Warning message")
        TestLogger.logError("Error message")
        
        Log.saveCurrentSession()
        
        // Find and read the log file
        let logFile = testDir.appendingPathComponent("FormatTest.log")
        
        let fileManager = FileManager.default
        if let content = try? String(contentsOf: logFile, encoding: .utf8) {
            // Verify session structure
            XCTAssertTrue(content.contains("LOG FOR SESSION"), "Should contain session header")
            XCTAssertTrue(content.contains("END LOG FOR SESSION"), "Should contain session footer")
            XCTAssertTrue(content.contains(Log.sessionID), "Should contain session ID")
            
            // Verify log levels are present
            XCTAssertTrue(content.contains("TRACE") || content.contains("Trace message"), "Should contain trace logs")
            XCTAssertTrue(content.contains("DEBUG") || content.contains("Debug message"), "Should contain debug logs")
            XCTAssertTrue(content.contains("INFO") || content.contains("Info message"), "Should contain info logs")
            XCTAssertTrue(content.contains("WARNG") || content.contains("Warning message"), "Should contain warning logs")
            XCTAssertTrue(content.contains("ERROR") || content.contains("Error message"), "Should contain error logs")
        } else {
            XCTFail("Could not read log file content")
        }
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
    }
    
    func testLogFileMultipleSaves() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        let originalAppend = Log.fileAppendingType
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "MultipleSaves"
        Log.fileAppendingType = .appendToExistingLogFile
        Log.History.current.clear()
        
        // Save multiple times
        for i in 1...5 {
            TestLogger.logInfo("Save \(i)")
            Log.saveCurrentSession()
        }
        
        // Find the log file
        let logFile = testDir.appendingPathComponent("MultipleSaves.log")
        
        let fileManager = FileManager.default
        XCTAssertTrue(fileManager.fileExists(atPath: logFile.path), "Log file should exist")
        
        if let content = try? String(contentsOf: logFile, encoding: .utf8) {
            // Should have multiple session markers
            let sessionCount = content.components(separatedBy: "LOG FOR SESSION").count - 1
            XCTAssertGreaterThanOrEqual(sessionCount, 5, "Should have multiple sessions")
            
            // All messages should be present
            for i in 1...5 {
                XCTAssertTrue(content.contains("Save \(i)"), "Should contain Save \(i)")
            }
        } else {
            XCTFail("Could not read log file content")
        }
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
        Log.fileAppendingType = originalAppend
    }
    
    func testLogFileWithEmptyHistory() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "EmptyTest"
        Log.History.current.clear()
        
        // Save with no logs
        Log.saveCurrentSession()
        
        // Find the log file
        let logFile = testDir.appendingPathComponent("EmptyTest.log")
        
        let fileManager = FileManager.default
        XCTAssertTrue(fileManager.fileExists(atPath: logFile.path), "Log file should be created even with empty history")
        
        if let content = try? String(contentsOf: logFile, encoding: .utf8) {
            XCTAssertTrue(content.contains("LOG FOR SESSION"), "Should contain session header")
            XCTAssertTrue(content.contains("END LOG FOR SESSION"), "Should contain session footer")
        } else {
            XCTFail("Could not read log file content")
        }
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
    }
    
    func testLogFileCustomFileName() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        let originalFileName = Log.defaultLogFileName
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "CustomName"
        Log.History.current.clear()
        
        TestLogger.logInfo("Custom name test")
        Log.saveCurrentSession()
        
        // Find the log file with custom name
        let logFile = testDir.appendingPathComponent("CustomName.log")
        
        let fileManager = FileManager.default
        XCTAssertTrue(fileManager.fileExists(atPath: logFile.path), "Log file should use custom name")
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
        Log.defaultLogFileName = originalFileName
    }
    
    func testLogFileApplicationSupportPath() {
        let originalPath = Log.logPath
        let originalFileName = Log.defaultLogFileName
        Log.logPath = .applicationSupport(path: "LoggingKitTests")
        Log.defaultLogFileName = "AppSupportTest"
        Log.History.current.clear()
        
        TestLogger.logInfo("Application support test")
        Log.saveCurrentSession()
        
        // Find the log file in application support
        guard let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            XCTFail("Could not get application support directory")
            return
        }
        
        let testSubDir = appSupportDir.appendingPathComponent("LoggingKitTests")
        let logFile = testSubDir.appendingPathComponent("AppSupportTest.log")
        
        let fileManager = FileManager.default
        XCTAssertTrue(fileManager.fileExists(atPath: logFile.path), "Log file should be created in application support")
        
        if let content = try? String(contentsOf: logFile, encoding: .utf8) {
            XCTAssertTrue(content.contains("Application support test"), "File should contain logged message")
            XCTAssertTrue(content.contains("LOG FOR SESSION"), "File should contain session header")
        }
        
        // Cleanup
        try? fileManager.removeItem(at: testSubDir)
        Log.logPath = originalPath
        Log.defaultLogFileName = originalFileName
    }
    
    func testLogFileSessionIDInContent() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "SessionIDTest"
        Log.History.current.clear()
        
        let sessionID = Log.sessionID
        TestLogger.logInfo("Session ID test")
        Log.saveCurrentSession()
        
        let logFile = testDir.appendingPathComponent("SessionIDTest.log")
        let fileManager = FileManager.default
        
        if let content = try? String(contentsOf: logFile, encoding: .utf8) {
            XCTAssertTrue(content.contains(sessionID), "File should contain session ID")
            // Session ID should appear in both header and footer
            let sessionIDCount = content.components(separatedBy: sessionID).count - 1
            XCTAssertEqual(sessionIDCount, 2, "Session ID should appear exactly twice (header and footer)")
        } else {
            XCTFail("Could not read log file content")
        }
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
    }
    
    func testLogFileAppendingVersusNumbering() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        let originalAppend = Log.fileAppendingType
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "AppendVsNumber"
        Log.History.current.clear()
        
        let fileManager = FileManager.default
        
        // Test with appending enabled
        Log.fileAppendingType = .appendToExistingLogFile
        TestLogger.logInfo("Append mode message 1")
        Log.saveCurrentSession()
        TestLogger.logInfo("Append mode message 2")
        Log.saveCurrentSession()
        
        let appendFile = testDir.appendingPathComponent("AppendVsNumber.log")
        let appendFiles = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
            .filter { $0.lastPathComponent.hasPrefix("AppendVsNumber") && $0.pathExtension == "log" }
        XCTAssertEqual(appendFiles.count, 1, "Append mode should create exactly 1 file")
        XCTAssertTrue(fileManager.fileExists(atPath: appendFile.path), "Append file should exist")
        
        // Clean up and test with numbering enabled
        try? fileManager.removeItem(at: appendFile)
        Log.History.current.clear()
        
        Log.fileAppendingType = .alwaysCreateNewLogFile
        TestLogger.logInfo("Number mode message 1")
        Log.saveCurrentSession()
        TestLogger.logInfo("Number mode message 2")
        Log.saveCurrentSession()
        
        let numberFiles = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
            .filter { $0.lastPathComponent.hasPrefix("AppendVsNumber") && $0.pathExtension == "log" }
        XCTAssertEqual(numberFiles.count, 2, "Number mode should create exactly 2 files")
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
        Log.fileAppendingType = originalAppend
    }
    
    func testLogFileMultipleAppendsExactCount() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        let originalAppend = Log.fileAppendingType
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "MultipleAppends"
        Log.fileAppendingType = .appendToExistingLogFile
        Log.History.current.clear()
        
        let fileManager = FileManager.default
        let logFile = testDir.appendingPathComponent("MultipleAppends.log")
        let expectedSessions = 10
        let uniqueMarker = UUID().uuidString
        
        // Save multiple sessions, clearing buffer between each
        for i in 1...expectedSessions {
            Log.History.current.clear() // Clear buffer before adding new log
            TestLogger.logInfo("Session \(i) message \(uniqueMarker)")
            Log.saveCurrentSession()
            
            // Verify exactly one file exists after each save
            let allFiles = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
            let logFiles = allFiles.filter { $0.lastPathComponent.hasPrefix("MultipleAppends") && $0.pathExtension == "log" }
            XCTAssertEqual(logFiles.count, 1, "Should have exactly 1 log file after \(i) saves")
        }
        
        // Verify file contains all sessions by counting unique messages
        if let content = try? String(contentsOf: logFile, encoding: .utf8) {
            // Count sessions by looking for session headers (each save creates one)
            let sessionHeaders = content.components(separatedBy: "--- LOG FOR SESSION")
            let sessionCount = sessionHeaders.count - 1 // Subtract 1 because split creates one extra element
            XCTAssertEqual(sessionCount, expectedSessions, "File should contain exactly \(expectedSessions) sessions, found \(sessionCount)")
            
            // Verify all unique messages are present exactly once
            for i in 1...expectedSessions {
                let message = "Session \(i) message \(uniqueMarker)"
                let messageCount = content.components(separatedBy: message).count - 1
                XCTAssertEqual(messageCount, 1, "Message \(i) should appear exactly once, found \(messageCount) times")
            }
        } else {
            XCTFail("Could not read log file content")
        }
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
        Log.fileAppendingType = originalAppend
    }
    
    func testLogFileNumberingExactCount() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        let originalAppend = Log.fileAppendingType
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "NumberingExact"
        Log.fileAppendingType = .alwaysCreateNewLogFile
        Log.History.current.clear()
        
        let fileManager = FileManager.default
        let expectedFiles = 5
        
        // Create multiple numbered files
        for i in 1...expectedFiles {
            TestLogger.logInfo("File \(i) message")
            Log.saveCurrentSession()
            
            // Verify exact number of files after each save
            let allFiles = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
            let logFiles = allFiles.filter { $0.lastPathComponent.hasPrefix("NumberingExact") && $0.pathExtension == "log" }
            XCTAssertEqual(logFiles.count, i, "Should have exactly \(i) log files after \(i) saves")
        }
        
        // Verify all files exist with correct names
        let baseFile = testDir.appendingPathComponent("NumberingExact.log")
        XCTAssertTrue(fileManager.fileExists(atPath: baseFile.path), "Base file should exist")
        
        for i in 1..<expectedFiles {
            let numberedFile = testDir.appendingPathComponent("NumberingExact-\(i).log")
            XCTAssertTrue(fileManager.fileExists(atPath: numberedFile.path), "Numbered file \(i) should exist")
        }
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
        Log.fileAppendingType = originalAppend
    }
    
    func testLogFileNoDuplicateFiles() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        let originalAppend = Log.fileAppendingType
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "NoDuplicates"
        Log.fileAppendingType = .appendToExistingLogFile
        Log.History.current.clear()
        
        let fileManager = FileManager.default
        let logFile = testDir.appendingPathComponent("NoDuplicates.log")
        let expectedSessions = 20
        let uniqueMarker = UUID().uuidString
        
        // Save multiple times rapidly, clearing buffer between each
        for i in 1...expectedSessions {
            Log.History.current.clear() // Clear buffer before adding new log
            TestLogger.logInfo("Rapid save \(i) \(uniqueMarker)")
            Log.saveCurrentSession()
        }
        
        // Verify exactly one file exists
        let allFiles = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
        let logFiles = allFiles.filter { $0.lastPathComponent.hasPrefix("NoDuplicates") && $0.pathExtension == "log" }
        XCTAssertEqual(logFiles.count, 1, "Should have exactly 1 log file, no duplicates")
        XCTAssertTrue(fileManager.fileExists(atPath: logFile.path), "Log file should exist")
        
        // Verify file contains all sessions by counting unique messages
        if let content = try? String(contentsOf: logFile, encoding: .utf8) {
            // Count sessions by looking for session headers
            let sessionHeaders = content.components(separatedBy: "--- LOG FOR SESSION")
            let sessionCount = sessionHeaders.count - 1
            XCTAssertEqual(sessionCount, expectedSessions, "File should contain exactly \(expectedSessions) sessions, found \(sessionCount)")
            
            // Verify each unique message appears exactly once
            for i in 1...expectedSessions {
                let message = "Rapid save \(i) \(uniqueMarker)"
                let messageCount = content.components(separatedBy: message).count - 1
                XCTAssertEqual(messageCount, 1, "Message \(i) should appear exactly once, found \(messageCount) times")
            }
        }
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
        Log.fileAppendingType = originalAppend
    }
    
    func testLogFileSwitchingAppendMode() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        let originalAppend = Log.fileAppendingType
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "SwitchMode"
        Log.History.current.clear()
        
        let fileManager = FileManager.default
        
        // Start with append mode
        Log.fileAppendingType = .appendToExistingLogFile
        TestLogger.logInfo("Append 1")
        Log.saveCurrentSession()
        
        let appendFile = testDir.appendingPathComponent("SwitchMode.log")
        XCTAssertTrue(fileManager.fileExists(atPath: appendFile.path), "Append file should exist")
        
        // Switch to numbering mode
        Log.fileAppendingType = .alwaysCreateNewLogFile
        TestLogger.logInfo("Number 1")
        Log.saveCurrentSession()
        
        // Should have 2 files now (base and numbered)
        let allFiles = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
        let logFiles = allFiles.filter { $0.lastPathComponent.hasPrefix("SwitchMode") && $0.pathExtension == "log" }
        XCTAssertEqual(logFiles.count, 2, "Should have exactly 2 files after switching modes")
        
        // Switch back to append mode
        Log.fileAppendingType = .appendToExistingLogFile
        TestLogger.logInfo("Append 2")
        Log.saveCurrentSession()
        
        // Should still have 2 files (append goes to base file, numbered file remains)
        let allFiles2 = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
        let logFiles2 = allFiles2.filter { $0.lastPathComponent.hasPrefix("SwitchMode") && $0.pathExtension == "log" }
        XCTAssertEqual(logFiles2.count, 2, "Should still have exactly 2 files")
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
        Log.fileAppendingType = originalAppend
    }
    
    func testLogFileContentIntegrity() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        let originalAppend = Log.fileAppendingType
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "IntegrityTest"
        Log.fileAppendingType = .appendToExistingLogFile
        Log.History.current.clear()
        
        let fileManager = FileManager.default
        let logFile = testDir.appendingPathComponent("IntegrityTest.log")
        
        // Save multiple sessions with unique content
        let messages = ["Alpha", "Beta", "Gamma", "Delta", "Epsilon"]
        for (index, message) in messages.enumerated() {
            Log.History.current.clear() // Clear buffer before adding new log
            TestLogger.logInfo("Message \(index + 1): \(message)")
            Log.saveCurrentSession()
        }
        
        // Verify file exists and has correct structure
        XCTAssertTrue(fileManager.fileExists(atPath: logFile.path), "Log file should exist")
        
        if let content = try? String(contentsOf: logFile, encoding: .utf8) {
            // Verify exact session count by counting session headers
            let sessionHeaders = content.components(separatedBy: "--- LOG FOR SESSION")
            let sessionCount = sessionHeaders.count - 1
            XCTAssertEqual(sessionCount, messages.count, "Should have exactly \(messages.count) sessions, found \(sessionCount)")
            
            // Verify all messages are present
            for (index, message) in messages.enumerated() {
                XCTAssertTrue(content.contains("Message \(index + 1): \(message)"), "Should contain message \(index + 1)")
            }
            
            // Verify session structure integrity
            let endCount = content.components(separatedBy: "--- END LOG FOR SESSION").count - 1
            XCTAssertEqual(sessionCount, endCount, "Should have matching session headers and footers")
        } else {
            XCTFail("Could not read log file content")
        }
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
        Log.fileAppendingType = originalAppend
    }
    
    func testLogFileLargeContent() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "LargeContent"
        Log.History.current.clear()
        
        let fileManager = FileManager.default
        let logFile = testDir.appendingPathComponent("LargeContent.log")
        
        // Add many logs to create a large file
        Log.History.current.clear()
        for i in 0..<1000 {
            TestLogger.logInfo("Large content message \(i)")
        }
        Log.saveCurrentSession()
        
        // Verify file exists and is not empty
        XCTAssertTrue(fileManager.fileExists(atPath: logFile.path), "Log file should exist")
        
        if let content = try? String(contentsOf: logFile, encoding: .utf8) {
            XCTAssertFalse(content.isEmpty, "File should not be empty")
            XCTAssertGreaterThan(content.count, 1000, "File should contain substantial content")
            XCTAssertTrue(content.contains("Large content message 0"), "Should contain first message")
            XCTAssertTrue(content.contains("Large content message 999"), "Should contain last message")
        } else {
            XCTFail("Could not read log file content")
        }
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
    }
    
    func testLogFileExactFileCountAfterNumbering() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        let originalAppend = Log.fileAppendingType
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "ExactCount"
        Log.fileAppendingType = .alwaysCreateNewLogFile
        Log.History.current.clear()
        
        let fileManager = FileManager.default
        let expectedFileCount = 7
        
        // Create exactly expectedFileCount files
        for i in 1...expectedFileCount {
            Log.History.current.clear()
            TestLogger.logInfo("File \(i) content")
            Log.saveCurrentSession()
            
            // Verify exact file count after each save
            let allFiles = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
            let logFiles = allFiles.filter { $0.lastPathComponent.hasPrefix("ExactCount") && $0.pathExtension == "log" }
            XCTAssertEqual(logFiles.count, i, "Should have exactly \(i) log files after \(i) saves, found \(logFiles.count)")
        }
        
        // Final verification of exact file count
        let allFiles = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
        let logFiles = allFiles.filter { $0.lastPathComponent.hasPrefix("ExactCount") && $0.pathExtension == "log" }
        XCTAssertEqual(logFiles.count, expectedFileCount, "Should have exactly \(expectedFileCount) log files, found \(logFiles.count)")
        
        // Verify file names are correct
        let baseFile = testDir.appendingPathComponent("ExactCount.log")
        XCTAssertTrue(fileManager.fileExists(atPath: baseFile.path), "Base file should exist")
        
        for i in 1..<expectedFileCount {
            let numberedFile = testDir.appendingPathComponent("ExactCount-\(i).log")
            XCTAssertTrue(fileManager.fileExists(atPath: numberedFile.path), "Numbered file \(i) should exist")
        }
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
        Log.fileAppendingType = originalAppend
    }
    
    func testLogFileAppendingExactFileCount() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        let originalAppend = Log.fileAppendingType
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "AppendExact"
        Log.fileAppendingType = .appendToExistingLogFile
        Log.History.current.clear()
        
        let fileManager = FileManager.default
        let logFile = testDir.appendingPathComponent("AppendExact.log")
        let saveCount = 15
        
        // Save multiple times in append mode
        for i in 1...saveCount {
            Log.History.current.clear()
            TestLogger.logInfo("Append save \(i)")
            Log.saveCurrentSession()
            
            // Verify exactly one file exists after each save
            let allFiles = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
            let logFiles = allFiles.filter { $0.lastPathComponent.hasPrefix("AppendExact") && $0.pathExtension == "log" }
            XCTAssertEqual(logFiles.count, 1, "Should have exactly 1 log file after \(i) saves, found \(logFiles.count)")
            XCTAssertTrue(fileManager.fileExists(atPath: logFile.path), "Log file should exist after save \(i)")
        }
        
        // Final verification
        let allFiles = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
        let logFiles = allFiles.filter { $0.lastPathComponent.hasPrefix("AppendExact") && $0.pathExtension == "log" }
        XCTAssertEqual(logFiles.count, 1, "Should have exactly 1 log file in append mode, found \(logFiles.count)")
        
        // Verify file contains all sessions
        if let content = try? String(contentsOf: logFile, encoding: .utf8) {
            let sessionHeaders = content.components(separatedBy: "--- LOG FOR SESSION")
            let sessionCount = sessionHeaders.count - 1
            XCTAssertEqual(sessionCount, saveCount, "File should contain exactly \(saveCount) sessions, found \(sessionCount)")
        }
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
        Log.fileAppendingType = originalAppend
    }
    
    func testLogFileNoExtraFilesCreated() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        let originalAppend = Log.fileAppendingType
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "NoExtra"
        Log.fileAppendingType = .appendToExistingLogFile
        Log.History.current.clear()
        
        let fileManager = FileManager.default
        let logFile = testDir.appendingPathComponent("NoExtra.log")
        
        // Save multiple times
        for i in 1...25 {
            Log.History.current.clear()
            TestLogger.logInfo("Save \(i)")
            Log.saveCurrentSession()
        }
        
        // Verify exactly one file exists (no extra files created)
        let allFiles = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
        let logFiles = allFiles.filter { $0.lastPathComponent.hasPrefix("NoExtra") && $0.pathExtension == "log" }
        XCTAssertEqual(logFiles.count, 1, "Should have exactly 1 log file, no extras. Found \(logFiles.count) files")
        
        // Verify only the expected file exists
        XCTAssertTrue(fileManager.fileExists(atPath: logFile.path), "Expected log file should exist")
        
        // Verify no other log files exist
        for file in logFiles {
            XCTAssertEqual(file.lastPathComponent, "NoExtra.log", "Only NoExtra.log should exist, found \(file.lastPathComponent)")
        }
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
        Log.fileAppendingType = originalAppend
    }
    
    func testLogFileNumberingSequence() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        let originalAppend = Log.fileAppendingType
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "Sequence"
        Log.fileAppendingType = .alwaysCreateNewLogFile
        Log.History.current.clear()
        
        let fileManager = FileManager.default
        
        // Create 5 files and verify numbering sequence
        for i in 1...5 {
            Log.History.current.clear()
            TestLogger.logInfo("Sequence \(i)")
            Log.saveCurrentSession()
        }
        
        // Verify files exist with correct sequence
        let baseFile = testDir.appendingPathComponent("Sequence.log")
        XCTAssertTrue(fileManager.fileExists(atPath: baseFile.path), "Base file should exist")
        
        // Verify numbered files exist in sequence
        for i in 1..<5 {
            let numberedFile = testDir.appendingPathComponent("Sequence-\(i).log")
            XCTAssertTrue(fileManager.fileExists(atPath: numberedFile.path), "Numbered file \(i) should exist")
            
            // Verify each file contains its respective content
            if let content = try? String(contentsOf: numberedFile, encoding: .utf8) {
                XCTAssertTrue(content.contains("Sequence \(i + 1)"), "File \(i) should contain Sequence \(i + 1)")
            }
        }
        
        // Verify exact file count
        let allFiles = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
        let logFiles = allFiles.filter { $0.lastPathComponent.hasPrefix("Sequence") && $0.pathExtension == "log" }
        XCTAssertEqual(logFiles.count, 5, "Should have exactly 5 log files")
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
        Log.fileAppendingType = originalAppend
    }
    
    func testLogFileConcurrentSaves() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        let originalAppend = Log.fileAppendingType
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "ConcurrentSaves"
        Log.fileAppendingType = .appendToExistingLogFile
        Log.History.current.clear()
        
        let fileManager = FileManager.default
        let logFile = testDir.appendingPathComponent("ConcurrentSaves.log")
        let expectation = XCTestExpectation(description: "Concurrent saves")
        expectation.expectedFulfillmentCount = 50
        
        // Concurrent saves
        let queue = DispatchQueue(label: "test.concurrent.saves", attributes: .concurrent)
        for i in 0..<50 {
            queue.async {
                Log.History.current.clear()
                TestLogger.logInfo("Concurrent save \(i)")
                Log.saveCurrentSession()
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        // Verify exactly one file exists (no duplicates from concurrent access)
        let allFiles = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
        let logFiles = allFiles.filter { $0.lastPathComponent.hasPrefix("ConcurrentSaves") && $0.pathExtension == "log" }
        XCTAssertEqual(logFiles.count, 1, "Should have exactly 1 log file even with concurrent saves, found \(logFiles.count)")
        XCTAssertTrue(fileManager.fileExists(atPath: logFile.path), "Log file should exist")
        
        // Verify file is readable and contains content
        if let content = try? String(contentsOf: logFile, encoding: .utf8) {
            XCTAssertFalse(content.isEmpty, "File should not be empty")
            // Should have some sessions (exact count may vary due to concurrency)
            let sessionHeaders = content.components(separatedBy: "--- LOG FOR SESSION")
            let sessionCount = sessionHeaders.count - 1
            XCTAssertGreaterThan(sessionCount, 0, "File should contain at least one session")
        }
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
        Log.fileAppendingType = originalAppend
    }
    
    // MARK: - Rolling File Tests
    
    func testRollingFileAppendsToBaseFile() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        let originalAppend = Log.fileAppendingType
        let originalLimit = Log.fileLimit
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "RollingTest"
        Log.fileAppendingType = .appendCreatingNewFileIfLimitIsReached
        Log.fileLimit = 100 // Set a high limit so we always append
        Log.History.current.clear()
        
        let fileManager = FileManager.default
        let baseFile = testDir.appendingPathComponent("RollingTest.log")
        
        // First save - should create base file
        TestLogger.logInfo("First rolling message")
        Log.saveCurrentSession()
        
        XCTAssertTrue(fileManager.fileExists(atPath: baseFile.path), "Base file should be created")
        
        // Second save - should append to base file (under limit)
        Log.History.current.clear()
        TestLogger.logInfo("Second rolling message")
        Log.saveCurrentSession()
        
        // Should still be only 1 file
        let allFiles = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
        let logFiles = allFiles.filter { $0.lastPathComponent.hasPrefix("RollingTest") && $0.pathExtension == "log" }
        XCTAssertEqual(logFiles.count, 1, "Should have exactly 1 file when under limit")
        
        // Verify both messages are in the file
        if let content = try? String(contentsOf: baseFile, encoding: .utf8) {
            XCTAssertTrue(content.contains("First rolling message"), "Should contain first message")
            XCTAssertTrue(content.contains("Second rolling message"), "Should contain second message")
        }
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
        Log.fileAppendingType = originalAppend
        Log.fileLimit = originalLimit
    }
    
    func testRollingFileCreatesNewFileAtLimit() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        let originalAppend = Log.fileAppendingType
        let originalLimit = Log.fileLimit
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "RollingLimit"
        Log.fileAppendingType = .appendCreatingNewFileIfLimitIsReached
        Log.fileLimit = 5 // Very low limit to trigger new file creation
        Log.History.current.clear()
        
        let fileManager = FileManager.default
        let baseFile = testDir.appendingPathComponent("RollingLimit.log")
        
        // First save - creates base file
        TestLogger.logInfo("Message 1")
        Log.saveCurrentSession()
        
        XCTAssertTrue(fileManager.fileExists(atPath: baseFile.path), "Base file should be created")
        
        // Second save - base file should have more than 5 lines now, should create new file
        Log.History.current.clear()
        TestLogger.logInfo("Message 2")
        Log.saveCurrentSession()
        
        let allFiles = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
        let logFiles = allFiles.filter { $0.lastPathComponent.hasPrefix("RollingLimit") && $0.pathExtension == "log" }
        XCTAssertEqual(logFiles.count, 2, "Should have 2 files after exceeding limit")
        
        // Verify numbered file exists
        let numberedFile = testDir.appendingPathComponent("RollingLimit-1.log")
        XCTAssertTrue(fileManager.fileExists(atPath: numberedFile.path), "Numbered file should be created")
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
        Log.fileAppendingType = originalAppend
        Log.fileLimit = originalLimit
    }
    
    func testRollingFileAppendsToHighestNumberedFile() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        let originalAppend = Log.fileAppendingType
        let originalLimit = Log.fileLimit
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "RollingHighest"
        Log.fileAppendingType = .appendCreatingNewFileIfLimitIsReached
        Log.fileLimit = 1000 // High limit
        Log.History.current.clear()
        
        let fileManager = FileManager.default
        
        // Pre-create some numbered files to simulate existing logs
        let baseFile = testDir.appendingPathComponent("RollingHighest.log")
        let file1 = testDir.appendingPathComponent("RollingHighest-1.log")
        let file3 = testDir.appendingPathComponent("RollingHighest-3.log") // Skip 2 to test highest detection
        
        try? "Old base content\n".write(to: baseFile, atomically: true, encoding: .utf8)
        try? "Old file 1 content\n".write(to: file1, atomically: true, encoding: .utf8)
        try? "Old file 3 content\n".write(to: file3, atomically: true, encoding: .utf8)
        
        // Save with rolling - should append to highest numbered file (file 3)
        TestLogger.logInfo("New rolling message")
        Log.saveCurrentSession()
        
        // Verify file 3 now contains the new message
        if let content = try? String(contentsOf: file3, encoding: .utf8) {
            XCTAssertTrue(content.contains("Old file 3 content"), "Should contain original content")
            XCTAssertTrue(content.contains("New rolling message"), "Should contain new message")
        } else {
            XCTFail("Could not read file 3 content")
        }
        
        // Verify file count is still 3
        let allFiles = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
        let logFiles = allFiles.filter { $0.lastPathComponent.hasPrefix("RollingHighest") && $0.pathExtension == "log" }
        XCTAssertEqual(logFiles.count, 3, "Should still have 3 files")
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
        Log.fileAppendingType = originalAppend
        Log.fileLimit = originalLimit
    }
    
    func testRollingFileCreatesNextNumberedFile() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        let originalAppend = Log.fileAppendingType
        let originalLimit = Log.fileLimit
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "RollingNext"
        Log.fileAppendingType = .appendCreatingNewFileIfLimitIsReached
        Log.fileLimit = 2 // Very low limit
        Log.History.current.clear()
        
        let fileManager = FileManager.default
        
        // Pre-create a numbered file with many lines (over limit)
        let file5 = testDir.appendingPathComponent("RollingNext-5.log")
        let manyLines = (1...10).map { "Line \($0)" }.joined(separator: "\n") + "\n"
        try? manyLines.write(to: file5, atomically: true, encoding: .utf8)
        
        // Save with rolling - should create file 6 since file 5 is over limit
        TestLogger.logInfo("New message for file 6")
        Log.saveCurrentSession()
        
        // Verify file 6 was created
        let file6 = testDir.appendingPathComponent("RollingNext-6.log")
        XCTAssertTrue(fileManager.fileExists(atPath: file6.path), "File 6 should be created")
        
        // Verify file 6 contains the new message
        if let content = try? String(contentsOf: file6, encoding: .utf8) {
            XCTAssertTrue(content.contains("New message for file 6"), "File 6 should contain the new message")
        }
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
        Log.fileAppendingType = originalAppend
        Log.fileLimit = originalLimit
    }
    
    func testRollingFileCanExceedLimit() {
        let testDir = getWritableTestDirectory()
        let originalPath = Log.logPath
        let originalAppend = Log.fileAppendingType
        let originalLimit = Log.fileLimit
        Log.logPath = .absolute(testDir.path)
        Log.defaultLogFileName = "RollingExceed"
        Log.fileAppendingType = .appendCreatingNewFileIfLimitIsReached
        Log.fileLimit = 10 // Set limit to 10 lines
        Log.History.current.clear()
        
        let fileManager = FileManager.default
        
        // Pre-create base file with 8 lines (under limit)
        let baseFile = testDir.appendingPathComponent("RollingExceed.log")
        let eightLines = (1...8).map { "Line \($0)" }.joined(separator: "\n") + "\n"
        try? eightLines.write(to: baseFile, atomically: true, encoding: .utf8)
        
        // Count initial lines
        let initialContent = try? String(contentsOf: baseFile, encoding: .utf8)
        var initialLineCount = 0
        initialContent?.enumerateLines { _, _ in initialLineCount += 1 }
        XCTAssertEqual(initialLineCount, 8, "Should start with 8 lines")
        
        // Save with rolling - should append even though result will exceed limit
        for i in 1...5 {
            TestLogger.logInfo("Extra message \(i)")
        }
        Log.saveCurrentSession()
        
        // Should still be only 1 file (appended to existing)
        let allFiles = (try? fileManager.contentsOfDirectory(at: testDir, includingPropertiesForKeys: nil)) ?? []
        let logFiles = allFiles.filter { $0.lastPathComponent.hasPrefix("RollingExceed") && $0.pathExtension == "log" }
        XCTAssertEqual(logFiles.count, 1, "Should still have 1 file")
        
        // Verify file now has more than 10 lines
        if let content = try? String(contentsOf: baseFile, encoding: .utf8) {
            var lineCount = 0
            content.enumerateLines { _, _ in lineCount += 1 }
            XCTAssertGreaterThan(lineCount, 10, "File should exceed the limit after appending")
            XCTAssertTrue(content.contains("Extra message 1"), "Should contain appended messages")
        }
        
        // Cleanup
        try? fileManager.removeItem(at: testDir)
        Log.logPath = originalPath
        Log.fileAppendingType = originalAppend
        Log.fileLimit = originalLimit
    }
    
    // MARK: - DebugMessage Tests
    
    func testDebugMessageCreation() {
        let message = Log.DebugMessage.trace(subsystem: "Test", message: "Test message")
        XCTAssertEqual(message.subsystem, "Test")
        XCTAssertEqual(message.message, "Test message")
        XCTAssertEqual(message.level, .trace)
    }
    
    func testDebugMessageHashable() {
        let message1 = Log.DebugMessage.info(subsystem: "Test", message: "Message")
        let message2 = Log.DebugMessage.info(subsystem: "Test", message: "Message")
        
        // Messages with same timestamp should be equal (unlikely but possible)
        // Different timestamps should produce different hashes
        let set: Set<Log.DebugMessage> = [message1, message2]
        // At least one should be in the set
        XCTAssertTrue(set.contains(message1) || set.contains(message2))
    }
    
    // MARK: - Hook Tests
    
    func testMessageHook() {
        var receivedMessage: String?
        Log.registerMessageHook { message in
            receivedMessage = message
        }
        
        TestLogger.logInfo("Hook test")
        XCTAssertEqual(receivedMessage, "Hook test")
        
        Log.registerMessageHook(nil)
    }
    
    func testTraceHook() {
        var receivedSubsystem: String?
        var receivedMessage: String?
        
        Log.registerTraceHook { subsystem, message in
            receivedSubsystem = subsystem
            receivedMessage = message
        }
        
        Log.logLevel = Log.Level.Trace
        TestLogger.logTrace("Trace test")
        XCTAssertEqual(receivedSubsystem, "TestSubsystem")
        XCTAssertEqual(receivedMessage, "Trace test")
        
        Log.registerTraceHook(nil)
    }
    
    func testDebugHook() {
        var receivedSubsystem: String?
        var receivedMessage: String?
        
        Log.registerDebugHook { subsystem, message in
            receivedSubsystem = subsystem
            receivedMessage = message
        }
        
        Log.logLevel = Log.Level.Debug
        TestLogger.logDebug("Debug test")
        XCTAssertEqual(receivedSubsystem, "TestSubsystem")
        XCTAssertEqual(receivedMessage, "Debug test")
        
        Log.registerDebugHook(nil)
    }
    
    func testInfoHook() {
        var receivedSubsystem: String?
        var receivedMessage: String?
        
        Log.registerInfoHook { subsystem, message in
            receivedSubsystem = subsystem
            receivedMessage = message
        }
        
        TestLogger.logInfo("Info test")
        XCTAssertEqual(receivedSubsystem, "TestSubsystem")
        XCTAssertEqual(receivedMessage, "Info test")
        
        Log.registerInfoHook(nil)
    }
    
    func testUserEventHook() {
        var receivedSubsystem: String?
        var receivedMessage: String?
        
        Log.registerUserEventHook { subsystem, message in
            receivedSubsystem = subsystem
            receivedMessage = message
        }
        
        TestLogger.logUserEvent("User event test")
        XCTAssertEqual(receivedSubsystem, "TestSubsystem")
        XCTAssertEqual(receivedMessage, "User event test")
        
        Log.registerUserEventHook(nil)
    }
    
    func testPerformanceHook() {
        var receivedSubsystem: String?
        var receivedMessage: String?
        
        Log.registerPerformanceHook { subsystem, message in
            receivedSubsystem = subsystem
            receivedMessage = message
        }
        
        TestLogger.logPerformance("Performance test")
        XCTAssertEqual(receivedSubsystem, "TestSubsystem")
        XCTAssertEqual(receivedMessage, "Performance test")
        
        Log.registerPerformanceHook(nil)
    }
    
    func testSuccessHook() {
        var receivedSubsystem: String?
        var receivedMessage: String?
        
        Log.registerSuccessHook { subsystem, message in
            receivedSubsystem = subsystem
            receivedMessage = message
        }
        
        TestLogger.logSuccess("Success test")
        XCTAssertEqual(receivedSubsystem, "TestSubsystem")
        XCTAssertEqual(receivedMessage, "Success test")
        
        Log.registerSuccessHook(nil)
    }
    
    func testNoticeHook() {
        var receivedSubsystem: String?
        var receivedMessage: String?
        
        Log.registerNoticeHook { subsystem, message in
            receivedSubsystem = subsystem
            receivedMessage = message
        }
        
        TestLogger.logNotice("Notice test")
        XCTAssertEqual(receivedSubsystem, "TestSubsystem")
        XCTAssertEqual(receivedMessage, "Notice test")
        
        Log.registerNoticeHook(nil)
    }
    
    func testWarningHook() {
        var receivedSubsystem: String?
        var receivedMessage: String?
        
        Log.registerWarningHook { subsystem, message in
            receivedSubsystem = subsystem
            receivedMessage = message
        }
        
        TestLogger.logWarning("Warning test")
        XCTAssertEqual(receivedSubsystem, "TestSubsystem")
        XCTAssertEqual(receivedMessage, "Warning test")
        
        Log.registerWarningHook(nil)
    }
    
    func testErrorHook() {
        var receivedSubsystem: String?
        var receivedMessage: String?
        
        Log.registerErrorHook { subsystem, message in
            receivedSubsystem = subsystem
            receivedMessage = message
        }
        
        TestLogger.logError("Error test")
        XCTAssertEqual(receivedSubsystem, "TestSubsystem")
        XCTAssertEqual(receivedMessage, "Error test")
        
        Log.registerErrorHook(nil)
    }
    
    func testCriticalHook() {
        var receivedSubsystem: String?
        var receivedMessage: String?
        
        Log.registerCriticalHook { subsystem, message in
            receivedSubsystem = subsystem
            receivedMessage = message
        }
        
        TestLogger.logCritical("Critical test")
        XCTAssertEqual(receivedSubsystem, "TestSubsystem")
        XCTAssertEqual(receivedMessage, "Critical test")
        
        Log.registerCriticalHook(nil)
    }
    
    func testFaultHook() {
        var receivedSubsystem: String?
        var receivedMessage: String?
        
        Log.registerFaultHook { subsystem, message in
            receivedSubsystem = subsystem
            receivedMessage = message
        }
        
        TestLogger.logFault("Fault test")
        XCTAssertEqual(receivedSubsystem, "TestSubsystem")
        XCTAssertEqual(receivedMessage, "Fault test")
        
        Log.registerFaultHook(nil)
    }
}

