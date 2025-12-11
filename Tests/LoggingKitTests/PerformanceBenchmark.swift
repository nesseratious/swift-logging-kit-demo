import XCTest
@testable import LoggingKit

/// Performance benchmark tests for AtomicLogBuffer optimizations
final class AtomicLogBufferPerformanceTests: XCTestCase {
    
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
    
    func testSyncModePerformance() {
        let buffer = AtomicLogBuffer(capacity: 100_000)
        
        measure {
            for i in 0..<100_000 {
                buffer.append("Log message \(i)")
            }
        }
        
        print("Sync mode completed")
    }
    
    
    func testHighContentionPerformance() {  
        let buffer = AtomicLogBuffer(capacity: 1_000_000)
        let expectation = XCTestExpectation(description: "High contention")
        expectation.expectedFulfillmentCount = 20
        
        let startTime = Date()
        
        for threadId in 0..<20 {
            DispatchQueue.global(qos: .userInitiated).async {
                for logId in 0..<50_000 {
                    buffer.append("T\(threadId)-L\(logId)")
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
        
        let duration = Date().timeIntervalSince(startTime)
        let throughput = 1_000_000.0 / duration
        
        print("High contention: \(Int(throughput)) logs/sec over 20 threads")
        XCTAssertGreaterThan(throughput, 500_000, "Should handle >500K logs/sec under contention")
    }
    
    func testMemoryEfficiency() {
        // Test that circular buffer properly reuses memory
        let buffer = AtomicLogBuffer(capacity: 100)
        
        // Fill buffer twice
        for i in 0..<200 {
            buffer.append("Log \(i)")
        }
        
        let result = buffer.converged()
        let logs = result.split(separator: "\n")
        
        // Should only contain capacity entries
        XCTAssertEqual(logs.count, 100, "Should cap at capacity")
        
        // Should contain newer logs
        XCTAssertTrue(result.contains("Log 199"))
        XCTAssertFalse(result.contains("Log 0"))
    }
}