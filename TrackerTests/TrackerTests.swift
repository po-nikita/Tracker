import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerViewControllerSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        SnapshotTesting.isRecording = false
    }

    func testTrackerViewControllerSnapshot() {
        let vc = TrackerViewController()
        
        vc.view.frame = CGRect(x: 0, y: 0, width: 375, height: 812)
        
        _ = vc.view
        
        assertSnapshot(matching: vc, as: .image)
    }
}
