# SION - Simplified, Improved Object Notation   

SION is an extension of JSON intended for use as a configuration and structured data file format. All valid JSON is valid SION. SION adds the following features to both simplify and improve on JSON.

* Comments using either `//` for line comments or `/*  */` for block comments
    - Comments are preserved through parsing and re-serialization
* Dictionary keys do not need to be quoted except when containing whitespace or `:` characters.
* String values and dictionary keys can use either double- or single-quotes obviating the need to escape quotations marks in the strings or keys in many cases.
* Dictionaries preserve key order by default
* Dates are supported as first-class value literals (unquoted) in any of the following formats:
    * `YYYY-MM-DD`
    * `YYYY/MM/DD`
    * `YYYY-MM-DD HH:mm:ss`
    * `YYYY/MM/DD HH:mm:ss`
* String values with no whitespaces can be left unquoted, for example when acting as enum literals
 
See the included sample file at `Tests/SIONTests/test.sion`

The Swift interface for the SION type borrows stylistically from the great SwiftyJSON project.
 
## Why?

JSON has significant shortcomings when it comes to using it for configuration, I personally find YAML to be so free-form as to be impossible to read, and TOML is too flat & minimal for my needs. 

I created SION for use as a configuration & data format for various personal projects in Swift. Thought it was cool and decided to open it as a reference or curiosity. I don't actually expect anyone else to use it, but if you do, cool! Let me know!

## Is that it?

The Date handling needs some refinement, but it works for what I need now. 

# Usage Examples

## Initialize from a file

```
    let sionFromString = try? SION(parsing: sionStringLoadedFromFile)
    let sionFromData = try? SION(parsing: sionDataLoadedFromFile)
```

## Initialize from literals

```
    // order is preserved!
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
    let maybeADeepValue = sion[someKey][someOtherKey][anIntIndex]["bast"].int // Int?
    let dynamicAccess = sion.foo.bar[3].bast.intValue  // Int
    let anEnumValue = sion.foo.as(MyEnum.self) // MyEnum?
```

## Direct Assignment

```
    var sion = SION()
    sion["the answer"] = 42
    sion["the question"] = "What do you get when you multiply six by nine?"
    sion.stringify(.json) // {"the answer":42,"the question":"What do you get when you multiply six by nine?"}
    
    var sion2 = SION()
    for i in 0..<1000 { 
        sion2[i] = "monkey\(i + 1)"
    }
    sion2.stringify(.json) // ["monkey1","monkey2","monkey3",...

```

## Output to String with Options

```
    sion.stringify(.pretty) // formatted for easy reading. Key order of dictionaries is preserved by default
    sion.stringify(.json) // outputs valid JSON
    sion.stringify([.sortKeys, .noTrailingComma, .stripComments]) // other options
```

