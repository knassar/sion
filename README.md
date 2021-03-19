# SION - Simplified, Improved Object Notation   

SION is an extension of JSON intended for use as a configuration and structured data file format. All valid JSON is valid SION. SION adds the following features to both simplify and improve on JSON.

* Comments using either `//` for line comments or `/*  */` for block comments
* Dictionary keys do not need to be quoted except when containing whitespace or `:` characters.
* String values and dictionary keys can use either double- or single-quotes obviating the need to escape quotations marks in the strings or keys in many cases.
* Dictionaries preserve key order by default
* Dates are supported as first-class value literals (unquoted) in any of the following formats:
    * `YYYY-MM-DD`
    * `YYYY/MM/DD`
    * `YYYY-MM-DD HH:mm:ss`
    * `YYYY/MM/DD HH:mm:ss`
 
See the included sample file at [`SIONTests/test.sion`](https://bitbucket.org/karimnassar/sion/src/d6839dacc4ffd0909995ebdec267533a465b8628/SIONTests/test.sion?at=master&fileviewer=file-view-default)

The Swift interface for the SION type borrows heavily from the great SwiftyJSON project.
 
## Why?

JSON has significant shortcomings when it comes to using it for configuration, I personally find YAML to be so free-form as to be impossible to read, and TOML is too flat & minimal for my needs. 

I created SION for use as a configuration & data format for various personal projects in Swift. Thought it was cool and decided to open it as a reference or curiosity. I don't actually expect anyone else to use it, but if you do, cool! Let me know!

## Is that it?

The Date handling needs some refinement, but it works for what I need now. 

I also may wind up adding more literal value types to SION as features like conditional conformance become available in Swift.

# Requirements

* Xcode 9+
* Swift 4+

# Installation

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# Usage Examples

## Initialize from a file

```
    let sionFromString = try? SION(parsing: sionStringLoadedFromFile)
    let sionFromData = try? SION(parsing: sionDataLoadedFromFile)
```

## Initialize from literals

```
    let sion = SION([
        "foo": "bar",
        "biff": 12345,
        "bast": true
    ])    
```

## Accessing Properties

```
    let bar = sion["foo"].string ?? "nothing" // String?
    let foo = sion["foo"].stringValue // String
    let maybeADeepValue = sion["foo"]["bar"][3]["bast"].int // Int?
    let variadicAccess = sion["foo", "bar", 3, "bast"].intValue  // Int
```

## Auto, Lazy Deep-intialization

```
    var sion = SION()
    sion["foo", "bar", 3, "bast"] = 42
    sion.stringify(.json) // {"foo":{"bar":[null,null,null,{"bast":42}]}}
```

## Output to String with Options

```
    sion.stringify(.pretty) // formatted for easy reading. Key order of dictionaries is preserved by default
    sion.stringify(.json) // outputs valid JSON
    sion.stringify([.sortKeys, .noTrailingComma]) // other options
```

