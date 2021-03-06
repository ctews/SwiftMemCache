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
    
    private let kUserDefaultsIdentifier = "CTMemCache"
    private var cache: Dictionary<String, CTMemCacheObject>
    
    init() {
        self.cache = [String:CTMemCacheObject]()
    }
    
    // MARK: - Setter + Getter
    
    func set(key: String, data:AnyObject?, namespace:String?="", ttl:Double=86400) {
        let cacheId = self.buildNamespacedKey(key, namespace: namespace)
        let calcedTtl = CFAbsoluteTimeGetCurrent() + ttl
        
        self.cache[cacheId] = CTMemCacheObject(data: data, ttl: calcedTtl)
    }
    
    func get(key:String, namespace:String?="") -> CTMemCacheObject? {
        var res: CTMemCacheObject? = nil
        
        if isExpired(key, namespace: namespace) {
           delete(key, namespace: namespace)
        }
        
        let cacheId: String = self.buildNamespacedKey(key, namespace: namespace)
        if exists(key, namespace: namespace) {
            res = self.cache[cacheId]
        }
        
        return res
    }
    
    // MARK: - MemCache State Info
    
    func isExpired(key:String, namespace:String?="") -> Bool {
        var isExpired:Bool = true
        let cacheId = buildNamespacedKey(key, namespace: namespace)
        
        if (self.cache[cacheId] != nil) {
            isExpired = ttlExpired(self.cache[cacheId]!.ttl)
        }
        
        return isExpired;
    }
    
    func isEmpty() -> Bool {
        return cache.isEmpty
    }
    
    func exists(key:String, namespace:String?="") -> Bool {
        let cacheId = buildNamespacedKey(key, namespace: namespace)
        return !isExpired(key, namespace: namespace)
    }
    
    func size() -> Int {
        return self.cache.count
    }
    
    // MARK: - Clean Functions
    func delete(key:String, namespace:String?="") {
        let cacheId = buildNamespacedKey(key, namespace: namespace)
        self.cache.removeValueForKey(cacheId)
    }
    
    func cleanNamespace(namespace: String) {
        let cacheIds = self.cache.keys
        
        for key in cacheIds {
            if key.rangeOfString(namespace) != nil {
                self.cache.removeValueForKey(key)
            }
        }
    }
    
    func deleteOutdated() {
        let cacheIds = self.cache.keys
        
        for key in cacheIds {
            if ttlExpired(self.cache[key]!.ttl) {
                self.cache.removeValueForKey(key)
            }
        }
    }
    
    func reset() {
        self.cache.removeAll(keepCapacity: false)
    }
    
    // MARK: - Persistence Functions
    func saveToDisk() -> Bool {
        // clear expired ttl before persist to disk
        deleteOutdated()
        
        // Write to NSUserDefaults
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        let cacheIds = self.cache.keys
        let convertedCache = NSMutableDictionary()
        
        for key in cacheIds {
            if let entry: CTMemCacheObject = self.cache[key] {
                let data: AnyObject? = entry.data
                let ttl = entry.ttl
                let dataContainer = NSMutableDictionary()
                dataContainer.setObject(data ?? "nil", forKey: "data")
                dataContainer.setObject(ttl, forKey: "ttl")
                
                convertedCache.setObject(dataContainer, forKey: key)
            }
        }
        
        userDefaults.setObject(convertedCache, forKey: kUserDefaultsIdentifier)
        return userDefaults.synchronize()
    }
    
    func restoreFromDisk() -> Bool {
        var success = false
        
        // Reset cache
        reset()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let data = userDefaults.dictionaryForKey(kUserDefaultsIdentifier) {
            let cacheIds = data.keys
            
            for key in cacheIds {
                if let entry = data[key] as? NSDictionary,
                   let ttl: Double = entry["ttl"] as? Double,
                   let id = key as? String {
                    
                    let data: AnyObject? = entry["data"]
                    let memCacheObject = CTMemCacheObject(data: data, ttl: ttl)
                    
                    self.cache[id] = memCacheObject
                }
            }
            
            success = true
        }
        
        return success
    }
    
    // MARK: - Private Functions
    
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