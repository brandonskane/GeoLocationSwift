//
//  GeoLocationTests.swift
//  GeoLocationTests
//
//  Created by Imri Goldberg on 11/1/18.
//  Copyright © 2018 Brandon S. Kane. All rights reserved.
//

import XCTest
import GeoLocation

class GeoLocationTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDistance() {
        do {
            let telaviv = try GeoLocation(degLatitude: 32.08088, degLongitude: 34.78057)
            let haifa = try GeoLocation(degLatitude: 32.81841, degLongitude: 34.9885)
            let distance = telaviv.distanceTo(haifa)
            XCTAssertEqual(distance, 84.0, accuracy: 1.0, "Distance should be about 84km")
            //XCTAssertTrue(83.0 < distance && distance < 85.0, "distance should be about 84Km, it is \(distance) instead")
            let distance2 = haifa.distanceTo(telaviv)
            let epsilon = 0.0001
            XCTAssertEqual(distance, distance2, accuracy: epsilon, "distances should be equal or close to equal")
            //XCTAssertTrue(distance - epsilon < distance2 && distance2 < distance + epsilon , "distances \(distance) and \(distance2) should be equal or close to equal")
        } catch {
            XCTFail("Should not throw exception at all")
        }
    }

    func testBoundingBox() {
        do {
            let telaviv = try GeoLocation(degLatitude: 32.08088, degLongitude: 34.78057)
            let haifa = try GeoLocation(degLatitude: 32.81841, degLongitude: 34.9885)
            let (minLoc, maxLoc) = try telaviv.boundingCoordinates(100)
            XCTAssertLessThan(minLoc.degLatitude, haifa.degLatitude, "Haifa lat should be in bounds")
            XCTAssertLessThan(haifa.degLatitude, maxLoc.degLatitude, "Haifa lat should be in bounds")
            XCTAssertLessThan(minLoc.degLongitude, haifa.degLongitude, "Haifa lng should be in bounds")
            XCTAssertLessThan(haifa.degLongitude, maxLoc.degLongitude, "Haifa lng should be in bounds")            
        } catch {
            XCTFail("Should not throw exception at all")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
