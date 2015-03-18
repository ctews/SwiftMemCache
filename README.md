#SwiftMemCache - A Swift Memory Cache
This project contains a Swift class that acts as a _memory cache_ (singleton). It supports optionally **_namespacing_** for the cache identifier. It also supports a **_TTL_** to invalidate a cashed data object after a certain time.

The purpose of this class is to provide data across the whole code structure with an easy access pattern. You can extract interesting data into the mem cache and access it via a shared instance from anywhere in your code. SwiftMemCache DOES NOT write data to disk!

SwiftMemCache is completely unit tested, to prove that everything works as expected!

## Features

### Add/Change Entry
Adds or changes a specified entry in the mem cache. Default TTL: -1 (object will always live in memory)

```swift 
CTMemCache.sharedInstance.set("foo", data:<YourObject>, namespace:"bar", ttl:3600)
```

```swift
CTMemCache.sharedInstance.set("foo", data:<YourObject>)
```

### Get
Return an entry if exists, otherwise returns ```nil```

```swift
CTMemCache.sharedInstance.get("foo", namespace:"bar")
```
```swift
CTMemCache.sharedInstance.get("foo")
```

### Delete
Deletes an entry by its key (namespace)

```swift
CTMemCache.sharedInstance.delete("foo", namespace:"bar")
```
```swift
CTMemCache.sharedInstance.delete("foo")
```

### Exists
Returns true if an entry with the given key (optional namespace) exists

```swift
CTMemCache.sharedInstance.exists("foo", namespace:"bar")
```


### Size
Returns the amount of the entries in the mem cache
```swift 
CTMemCache.sharedInstance.size()
```

### Clean Namespace
Deletes all entries of the given namespace from the mem cache

```swift
CTMemCache.sharedInstance.cleanNamespace("foo")
```

### Expired
Checks if an given entry is expired. Returns true/false

```swift
CTMemCache.sharedInstance.isExpired("foo", namespace:"bar")
```

### Delete Outdated Entries (TTL expired)
Cleans all entries in the mem cache where the TTL is expire

```swift
CTMemCache.sharedInstance.deleteOutdated()
```

### Reset
This wipes all the data from the mem cache:
```swift
CTMemCache.sharedInstance.reset()
```

## Requests
For feature requests or bugs open an issue or provide a unit tested Pull Request :-)
Find me on Twitter: @ctews

