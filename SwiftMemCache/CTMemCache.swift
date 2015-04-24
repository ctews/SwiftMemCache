//
//  CTMemCache.swift
//  SwiftMemCache
//
//  Created by Christoffer on 27.02.15.
//  Copyright (c) 2015 Christoffer Tews. All rights reserved.
//

import Foundation

// MARK: MemCache Data Types

struct CTMemCacheObjectData {
    var data: AnyObject?
    var ttl : Double
}

typealias CTMemCacheObject = CTMemCacheObjectData


class CTMemCache {
    
    static let sharedInstance = CTMemCache()
    private var cache: Dictionary<String, CTMemCacheObject>
    private let kDiskIdentifier = "CTMemCacheImage"
    
    init() {
        self.cache = [String:CTMemCacheObject]()
    }
    
    // MARK: Setter + Getter
    
    func set(key: String, data:AnyObject?, namespace:String?="", ttl:Double=86400) {
        var cacheId = self.buildNamespacedKey(key, namespace: namespace)
        var calcedTtl = CFAbsoluteTimeGetCurrent() + ttl
        
        self.cache[cacheId] = CTMemCacheObject(data: data, ttl: calcedTtl)
    }
    
    func get(key:String, namespace:String?="") -> CTMemCacheObject? {
        var res: CTMemCacheObject? = nil
        
        if isExpired(key, namespace: namespace) {
           delete(key, namespace: namespace)
        }
        
        var cacheId: String = self.buildNamespacedKey(key, namespace: namespace)
        if exists(key, namespace: namespace) {
            res = self.cache[cacheId]
        }
        
        return res
    }
    
    // MARK: MemCache Disk Save/Read
    func saveToDisk() -> Bool {
        var tmpDict = [NSObject:AnyObject]()
        for key in self.cache.keys {
            var dataObject = [NSObject:AnyObject]()
            dataObject["data"] = self.cache[key]!.data
            dataObject["ttl"] = self.cache[key]!.ttl
            tmpDict[key] = dataObject
        }
        
        var userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(tmpDict, forKey: kDiskIdentifier)
        return (self.cache.count == tmpDict.count) && userDefaults.synchronize()
    }
    
   func restoreFromDisk() -> Bool {
        var success = false
        var userDefaults = NSUserDefaults.standardUserDefaults()
        self.reset()

        if let nsDict = userDefaults.dictionaryForKey(kDiskIdentifier) {
            for key in nsDict.keys {
                var dataObject: [NSObject:AnyObject] = nsDict[key] as! [NSObject:AnyObject]
                self.cache[key as! String] = CTMemCacheObject(data: dataObject["data"], ttl: dataObject["ttl"] as! Double)
            }
            success = true
        } else {
            self.cache = [String:CTMemCacheObject]()
        }
        
        return success
    }
    
    
    
    /*func saveToDisk(namespace:String?) -> Bool {
        
        
        return true
    }*/
    
    // MARK: MemCache State Info
    
    func isExpired(key:String, namespace:String?="") -> Bool {
        var isExpired:Bool = true
        var cacheId = buildNamespacedKey(key, namespace: namespace)
        
        if (self.cache[cacheId] != nil) {
            isExpired = ttlExpired(self.cache[cacheId]!.ttl)
        }
        
        return isExpired;
    }
    
    func isEmpty() -> Bool {
        return cache.isEmpty
    }
    
    func exists(key:String, namespace:String?="") -> Bool {
        var cacheId = buildNamespacedKey(key, namespace: namespace)
        return cache[cacheId] != nil
    }
    
    func size() -> Int {
        return count(self.cache)
    }
    
    // MARK: Clean Functions
    func delete(key:String, namespace:String?="") {
        var cacheId = buildNamespacedKey(key, namespace: namespace)
        self.cache.removeValueForKey(cacheId)
    }
    
    func cleanNamespace(namespace: String) {
        var cacheIds = self.cache.keys
        
        for key in cacheIds {
            if key.rangeOfString(namespace) != nil {
                self.cache.removeValueForKey(key)
            }
        }
    }
    
    func deleteOutdated() {
        var cacheIds = self.cache.keys
        
        for key in cacheIds {
            if ttlExpired(self.cache[key]!.ttl) {
                self.cache.removeValueForKey(key)
            }
        }
    }
    
    func reset() {
        self.cache.removeAll(keepCapacity: false)
    }
    
    // MARK: Private Functions
    
    // Not declared private to be visible in unit tests
    func buildNamespacedKey(key:String, namespace:String?) -> String {
        var res: String = key
        
        if (namespace != nil) && (namespace != "") {
            res = namespace!+"_"+key
        }
        
        return res
    }
    
    private func ttlExpired(ttl:Double) -> Bool {
        return CFAbsoluteTimeGetCurrent() > ttl
    }
}