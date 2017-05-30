# SION - Simplified, Improved Object Notation   

SION is an extension of JSON intended for use as a configuration and structured data file format. All valid JSON is valid SION. SION adds the following features to both simplify and improve on JSON.

* Comments using either `//` for line comments or `/*  */` for block comments
* Dictionary keys do not need to be quoted except when containing whitespace or `:` characters.
* String values and dictionary keys can use either double- or single-quotes obviating the need to escape quotations marks in the strings or keys in many cases.
* Dates are supported as first-class value literals (unquoted) in any of the following formats:
    * `YYYY-MM-DD`
    * `YYYY/MM/DD`
    * `YYYY-MM-DD HH:mm:ss`
    * `YYYY/MM/DD HH:mm:ss`
 
See the included sample file at `SIONTests/test.sion`

The Swift interface for the SION type borrows heavily from the great SwiftyJSON project.
 
## Why?

I created SION for use as a configuration format for various personal projects in Swift. Thought it was cool and decided to open it as a reference or curiosity. I don't actually expect anyone else to use it, but if you do, cool!

## Is that it?

The Date handling needs some refinement, and it's early days–I may wind up adding more literal value types to SION. One thing I'm looking at for one project is the ability to support Swift enum literals, but that might have to wait for some Swift 4 features.

# Requirements

* Xcode 8.3+
* Swift 3.1+

# Usage

## Initialize from a file

```
    let sionFromString = try? SION(raw: sionStringLoadedFromFile)
    let sionFromData = try? SION(raw: sionDataLoadedFromFile)
```

## Initialize from code

```
    let sion = SION([
        "foo": "bar",
        "biff": 12345,
        "now": SION(Date())
    ])    
```

## Accessing Properties

```
    let foo = sion["foo"].stringValue
    let bar = sion["foo"].string ?? "nothing"
    let maybeADeepValue = sion["foo"]["bar"][3]["bast"].int
    let variadicAccess = sion["foo", "bar", 3, "bast"].int   
```