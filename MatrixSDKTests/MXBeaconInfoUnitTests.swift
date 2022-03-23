// 
// Copyright 2022 The Matrix.org Foundation C.I.C
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

import XCTest

@testable import MatrixSDK

class MXBeaconInfoUnitTests: XCTestCase {
        
    func testParsingSucceed() throws {
        
        let expectedDescription = "Live location description"
        let expectedTimeout: TimeInterval = 600000
        let expectedIsLive = true
        let expectedTimestamp: TimeInterval = 1436829458432
        
        let eventContentJSON: [String : Any] = [
            kMXEventTypeStringBeaconInfoMSC3489: [
                "description": expectedDescription,
                "timeout":  expectedTimeout,
                "live": expectedIsLive,
            ],
            kMXMessageContentKeyExtensibleTimestampMSC3488: expectedTimestamp,
            kMXMessageContentKeyExtensibleAssetMSC3488: [
                kMXMessageContentKeyExtensibleAssetType: kMXMessageContentKeyExtensibleAssetTypeLiveLocation
            ]
        ]

        let beaconInfo = MXBeaconInfo(fromJSON: eventContentJSON)

        guard let beaconInfo = beaconInfo else {
            XCTFail("Beacon info should not be nil")
            return
        }
        
        XCTAssertEqual(beaconInfo.desc, expectedDescription)
        XCTAssertEqual(beaconInfo.timeout, expectedTimeout)
        XCTAssertEqual(beaconInfo.isLive, expectedIsLive)
        XCTAssertEqual(beaconInfo.timestamp, expectedTimestamp)
        XCTAssertEqual(beaconInfo.assetType, MXEventAssetType.liveLocation)
    }
    
    func testParsingFailMissingTimeout() throws {
        
        let expectedDescription = "Live location description"
        let expectedIsLive = true
        let expectedTimestamp: TimeInterval = 1436829458432
        
        let eventContentJSON: [String : Any] = [
            kMXEventTypeStringBeaconInfoMSC3489: [
                "description": expectedDescription,
                "live": expectedIsLive,
            ],
            kMXMessageContentKeyExtensibleTimestampMSC3488: expectedTimestamp,
            kMXMessageContentKeyExtensibleAssetMSC3488: [
                kMXMessageContentKeyExtensibleAssetType: kMXMessageContentKeyExtensibleAssetTypeLiveLocation
            ]
        ]
        
        let beaconInfo = MXBeaconInfo(fromJSON: eventContentJSON)
                
        XCTAssertNil(beaconInfo)
    }
    
    func testJSONDictionarySucceed() throws {
                
        let expectedDescription = "Live location description"
        let expectedTimeout: TimeInterval = 600000
        let expectedIsLive = true
        
        let beaconInfo = MXBeaconInfo(description: expectedDescription, timeout: expectedTimeout, isLive: expectedIsLive)
        
        let jsonDictionary = beaconInfo.jsonDictionary()
            
        let beaconInfoCopy = MXBeaconInfo(fromJSON: jsonDictionary)
        
        XCTAssertNotNil(beaconInfoCopy)
        
        guard let beaconInfoCopy = beaconInfoCopy else {
            return
        }
        
        XCTAssertEqual(beaconInfo.desc, beaconInfoCopy.desc)
        XCTAssertEqual(beaconInfo.timeout, beaconInfoCopy.timeout)
        XCTAssertEqual(beaconInfo.isLive, beaconInfoCopy.isLive)
        XCTAssertEqual(beaconInfo.timestamp, beaconInfoCopy.timestamp)
        XCTAssertEqual(beaconInfo.assetType, beaconInfoCopy.assetType)
    }
    
    func testBuildEventTypeSucceed() throws {
        
        let expectedUserId = "@alice:matrix.org"
        let expectedUniqueId = "98088ZE98"
        let expectedUniqueSuffix = ".\(expectedUserId).\(expectedUniqueId)"
        
        let expectedFullEventTypeString = "\(kMXEventTypeStringBeaconInfoMSC3489)\(expectedUniqueSuffix)"
        
        let beaconInfoEventTypeComponents = MXBeaconInfoEventTypeComponents(eventTypeString: expectedFullEventTypeString)
        
        XCTAssertNotNil(beaconInfoEventTypeComponents)
        
        guard let beaconInfoEventTypeComponents = beaconInfoEventTypeComponents else {
            return
        }
        
//        XCTAssertEqual(beaconInfoEventTypeComponents.userId, expectedUserId)
//        XCTAssertEqual(beaconInfoEventTypeComponents.uniqueId, expectedUniqueId)
        XCTAssertEqual(beaconInfoEventTypeComponents.uniqueSuffix, expectedUniqueSuffix)
        XCTAssertEqual(beaconInfoEventTypeComponents.fullEventTypeString, expectedFullEventTypeString)
    }
    
    func testBuildEventTypeFail() throws {
        
        let eventTypeString = "m.bacon_info.@alice:matrix.org.98088ZE98"
        
        let beaconInfoEventTypeComponents = MXBeaconInfoEventTypeComponents(eventTypeString: eventTypeString)
        
        XCTAssertFalse(MXBeaconInfoEventTypeComponents.isEventTypeStringBeaconInfo(eventTypeString))        
        XCTAssertNil(beaconInfoEventTypeComponents)
    }
}
