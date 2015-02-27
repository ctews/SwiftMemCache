#SwiftMemCache - A Swift Memory Cache
This project contains a Swift class that acts as a _memory cache_ (singleton). It supports optionally **_namespacing_** for the cash identifier. It also supports a **_TTL_** to invalidate a cashed data object after a certain time.

The purpose of this class is to provide data across the whole code structure with an easy access pattern. You can extract interesting data into the mem cache and access it via a shared instance from anywhere in your code. SwiftMemCache DOES NOT write data to disk!

SwiftMemCache is completely unit tested, to prove that everything works as expected!

## Features

### Add/Change Entry
Adds or changes a specified entry in the mem cache. Default TTL: 86400

```CTMemCache.sharedInstance.set("foo", data:<YourObject>, namespace:"bar", ttl:3600)```

```CTMemCache.sharedInstance.set("foo", data:<YourObject>)```

### Get
Return an entry if exists, otherwise returns ```nil```

```CTMemCache.sharedInstance.get("foo", namespace:"bar")```
```CTMemCache.sharedInstance.get("foo")```

### Delete
Deletes an entry by its key (namespace)

```CTMemCache.sharedInstance.delete("foo", namespace:"bar")```

### Exists
Returns true if an entry with the given key (optional namespace) exists

```CTMemCache.sharedInstance.exists("foo", namespace:"bar")```


### Size
Returns the amount of the entries in the mem cache
```CTMemCache.sharedInstance.size()```
```

### Clean Namespace
Deletes all entries of the given namespace from the mem cache

```CTMemCache.sharedInstance.cleanNamespace("foo")```

### Expired
Checks if an given entry is expired. Returns true/false

```CTMemCache.sharedInstance.isExpired("foo", namespace:"bar")```

### Delete Outdated Entries (TTL expired)
Cleans all entries in the mem cache where the TTL is expire

```CTMemCache.sharedInstance.deleteOutdated()```

### Reset
This wipes all the data from the mem cache:
```CTMemCache.sharedInstance.reset()```

## Requests
For feature requests or bugs open an issue or provide a unit tested Pull Request :-)
Find me on Twitter: @ctews

