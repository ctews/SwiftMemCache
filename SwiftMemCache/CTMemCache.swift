//
//  CTMemCache.swift
//  SwiftMemCache
//
//  Created by Christoffer on 27.02.15.
//  Copyright (c) 2015 Christoffer Tews. All rights reserved.
//

import Foundation


struct CTMemCacheObjectData {
    var data: AnyObject?
    var ttl : Double
}

typealias CTMemCacheObject = CTMemCacheObjectData



class CTMemCache {
    
    static let sharedInstance = CTMemCache()
    internal var cache: Dictionary<String, CTMemCacheObject>
    
    init() {
        self.cache = [String:CTMemCacheObject]()
    }
    
    func buildNamespacedKey(key:String, namespace:String?) -> String {
        var res: String = key
        
        if (namespace != nil) && (namespace != "") {
            res = namespace!+"_"+key
        }
        
        return res
    }
    
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
    
    func isExpired(key:String, namespace:String?="") -> Bool {
        var isExpired:Bool = true
        var cacheId = buildNamespacedKey(key, namespace: namespace)
        
        if (self.cache[cacheId] != nil) {
            isExpired = ttlExpired(self.cache[cacheId]!.ttl)
        }
        
        return isExpired;
    }
    
    internal func ttlExpired(ttl:Double) -> Bool {
        return CFAbsoluteTimeGetCurrent() > ttl
    }
    
    func delete(key:String, namespace:String?="") {
        var cacheId = buildNamespacedKey(key, namespace: namespace)
        self.cache.removeValueForKey(cacheId)
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
}