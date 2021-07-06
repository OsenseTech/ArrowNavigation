//
//  ArrowNavigationTests.swift
//  ArrowNavigationTests
//
//  Created by 蘇健豪 on 2021/6/21.
//

import XCTest
import Accelerate

@testable import ArrowNavigation

class ArrowNavigationTests: XCTestCase {

    func testRotateVector_90() {
        let sut = ViewController()
        let originVector: SIMD2<Float> = SIMD2(1, 0)
        
        let angle = Measurement(value: 90, unit: UnitAngle.degrees)
        let radians = Float(angle.converted(to: .radians).value)
        let transferedVector = sut.rotateVector(originVector, angle: radians)
        
        XCTAssertEqual(transferedVector.y, -1)
    }
    
    func testRotateVector_90Nagative() {
        let sut = ViewController()
        let originVector: SIMD2<Float> = SIMD2(1, 0)
        
        let angle = Measurement(value: -90, unit: UnitAngle.degrees)
        let radians = Float(angle.converted(to: .radians).value)
        let transferedVector = sut.rotateVector(originVector, angle: radians)
        
        XCTAssertEqual(transferedVector.y, 1)
    }
    
    func testRotateVector_45() {
        let sut = ViewController()
        let originVector: SIMD2<Float> = SIMD2(1, 0)
        
        let angle = Measurement(value: 45, unit: UnitAngle.degrees)
        let radians = Float(angle.converted(to: .radians).value)
        let transferedVector = sut.rotateVector(originVector, angle: radians)
        
        XCTAssertEqual(transferedVector, SIMD2(cos(radians), -sin(radians)))
    }
    
    func testRotateVector_180() {
        let sut = ViewController()
        let originVector: SIMD2<Float> = SIMD2(1, 0)
        
        let angle = Measurement(value: 180, unit: UnitAngle.degrees)
        let radians = Float(angle.converted(to: .radians).value)
        let transferedVector = sut.rotateVector(originVector, angle: radians)
        
        XCTAssertEqual(transferedVector.x, -1)
    }
    
    func testRotateVector_270() {
        let sut = ViewController()
        let originVector: SIMD2<Float> = SIMD2(1, 0)
        
        let angle = Measurement(value: 270, unit: UnitAngle.degrees)
        let radians = Float(angle.converted(to: .radians).value)
        let transferedVector = sut.rotateVector(originVector, angle: radians)
        
        XCTAssertEqual(transferedVector.y, 1)
    }
    
    func testRotateVector_360() {
        let sut = ViewController()
        let originVector: SIMD2<Float> = SIMD2(1, 0)
        
        let angle = Measurement(value: 360, unit: UnitAngle.degrees)
        let radians = Float(angle.converted(to: .radians).value)
        let transferedVector = sut.rotateVector(originVector, angle: radians)
        
        XCTAssertEqual(transferedVector.x, 1)
    }
    
    func testRotateVector_23_287964() {
        let sut = ViewController()
        let originVector: SIMD2<Float> = SIMD2(-1, -1)
        
        let angle = Measurement(value: 23.287964, unit: UnitAngle.degrees)
        let radians = Float(angle.converted(to: .radians).value)
        let transferedVector = sut.rotateVector(originVector, angle: radians)
        
        XCTAssertEqual(transferedVector, SIMD2(-1.313882, -0.5231769))
    }

}
