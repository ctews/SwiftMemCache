//
//  SwiftMemCacheTests.swift
//  SwiftMemCacheTests
//
//  Created by Christoffer on 27.02.15.
//  Copyright (c) 2015 Christoffer Tews. All rights reserved.
//

import UIKit
import XCTest


class SwiftMemCacheTests: XCTestCase {
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        CTMemCache.sharedInstance.reset()
    }
    
    func testKeyBuilder() {
        let key = "mama"
        let namespace = "yo"
        let expectedResult = "yo_mama"
        XCTAssertEqual(CTMemCache.sharedInstance.buildNamespacedKey(key, namespace: namespace), expectedResult, "buildNamespacedKey() passed")
    }
    
    func testIsEmpty() {
        let memCache = CTMemCache.sharedInstance
        let isEmpty = memCache.isEmpty()
        XCTAssertTrue(isEmpty, "isEmpty() test passed")
    }
    
    func testSize() {
        let memCache = CTMemCache.sharedInstance
        XCTAssertEqual(memCache.size(), 0, "size() for empty mem cache passed")
        
        memCache.set("tmp", data: "StringObject")
        XCTAssertEqual(memCache.size(), 1, "size() for non empty mem cache passed")
    }
    
    func testExists() {
        let memCache = CTMemCache.sharedInstance
        memCache.set("tmp", data: "StringObject")
        XCTAssertTrue(memCache.exists("tmp"), "exists() test passed")
    }
    
    func testIsExpired() {
        let memCache = CTMemCache.sharedInstance
        memCache.set("tmp", data: "blubb", ttl: 0)
        XCTAssertTrue(memCache.isExpired("tmp"), "isExpired() with expired ttl test passed")
        
        memCache.set("tmp", data: "blubb", ttl: 10000)
        XCTAssertFalse(memCache.isExpired("tmp"), "isExpired() with valid ttl test passed")
        
        memCache.set("tmp", data: "blubb")
        XCTAssertFalse(memCache.isExpired("tmp"), "isExpired() with default ttl test passed")
    }
    
    func testSetAndGet() {
        let memCache = CTMemCache.sharedInstance
        memCache.set("tmp", data: "blubb", namespace: "ns")
        
        XCTAssertTrue(memCache.exists("tmp", namespace: "ns"), "exists() test passed")
        XCTAssertEqual(memCache.get("tmp", namespace: "ns")!.data as! String, "blubb", "set() data property passed")
    }
    
    func testDelete() {
        let memCache = CTMemCache.sharedInstance
        memCache.set("tmp", data: "blubb", namespace:"ns")
        memCache.delete("tmp", namespace:"ns")
        XCTAssertEqual(memCache.size(), 0, "delete() test passed")
    }
    
    func testCleanOutdated() {
        let memCache = CTMemCache.sharedInstance
        memCache.set("tmp0", data: "outdated", ttl:0)
        memCache.set("tmp1", data: "outdated", ttl:0)
        memCache.set("tmp2", data: "alive")
        memCache.deleteOutdated()
        
        XCTAssertEqual(memCache.size(), 1, "deleteOutdated() test passed")
        XCTAssertEqual(memCache.get("tmp2")!.data as! String, "alive", "deleteOutdated() selection passed")
    }
    
    func testCleanNamespace() {
        let memCache = CTMemCache.sharedInstance
        memCache.set("tmp0", data: "dead", namespace:"killme")
        memCache.set("tmp1", data: "dead", namespace:"killme")
        memCache.set("tmp2", data: "alive", namespace:"letmelive")
        memCache.set("tmp3", data: "alive")
        memCache.cleanNamespace("killme")
        XCTAssertEqual(memCache.size(), 2, "cleanNamespace() test passed")
        XCTAssertEqual(memCache.get("tmp2", namespace:"letmelive")!.data as! String, "alive", "cleanNamespace() selection passed")
        XCTAssertEqual(memCache.get("tmp3")!.data as! String, "alive", "cleanNamespace() selection passed")
    }
    
    func testReset() {
        let memCache = CTMemCache.sharedInstance
        memCache.set("tmp0", data: "blubb")
        memCache.reset()
        XCTAssertEqual(memCache.size(), 0, "reset() test passed")
    }
}
