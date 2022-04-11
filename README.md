# Ranasa: Select the architecture arm64 will be called

![swift 5.3](https://img.shields.io/badge/swift-5.3-orange.svg)
![platform macOS](https://img.shields.io/badge/platform-macOS-blue)
![SPM supported](https://img.shields.io/badge/SPM-supported-green)

[日本語のREADME](Docs/README_ja.md)

![logo image](Docs/logo.png)

macOS utility for selective arm64-linking-architecture for Library.
This tool was developed during the course of work at DMM.com.

## Description

`Ranasa` is a tool inspired by `darrarski/xcframework-maker`.

`xcframework-maker` can convert Fat-Architecture frameworks into XCFrameworks and generate arm64-sim compliant frameworks at the same time. On the other hand, `Ranasa` provides an approach to arm64-sim support for static and dynamic libraries. For static libraries, it rewrites the parts that are compiled in the `ar archive`, and for dynamic libraries, it rewrites the parts that are instructed to link arm64-sim in a suitable way.

Clang is the underlying technology that makes this possible. If the header file of the binary to be loaded is specific, Clang selects the target to be linked for the actual device or for the simulator. This tool provides a common interface to the static and dynamic libraries to manipulate this.

## Discussion

Why do we need a separate tool? The reason is to be able to maintain the application with as much of the existing workflow intact as possible. I assume that many of the projects that this tool will be used for are applications with a long history that have been inherited from the past. Therefore, if you are forced to use a tool that provides a new package to support arm64-sim, you will have to start a new research from the perspective of changing the way existing projects are organized.

Also, for projects that use the library directly, it is necessary to put each library into a framework. This is a very tedious task, and one I'd rather not do if at all possible. It would be very time consuming and resource intensive to write a lot of time and effort when I just want to develop using Xcode on a Mac with Apple Silicon and arm64. From PdM's point of view, it seems reasonable to decide not to spend the man-hours if it can be run via Rosetta2.

The team at DMM.com has several applications that we develop and maintain. One of the apps was facing the exact issue mentioned above, so we created this utility out of necessity.

## Reference

Rewriting the static library

https://bogo.wtf/arm64-to-sim.html

Rewriting dynamic libraries

https://bogo.wtf/arm64-to-sim-dylibs.html

Implementation Repository

https://github.com/bogo/arm64-to-sim

## Build

You can build this on macOS with Swift 5.3 or higher.

```shell
swift build -c release
```

The output is an executable file, so you can treat it like a regular CLI application.

```shell
.build/release/ranasa
````

If you want to run it in the Xcode build script, you can add Mint to your project and issue the `Ranasa` command to use it.

```shell
export PATH="/opt/homebrew/bin:$PATH"
xcrun --sdk macosx mint install ranasa
mint run ranasa -s ${SRCROOT}/binaries -r ${SRCROOT} -v -x arm64sim.json
```

## Usage

```text
$ ranasa -h
OVERVIEW: `ranasa` is utility for switch architecture from legacy static library, static framework, dynamic library, dynamic framework.

The design idea is to make binary libraries that depend on projects built with
older designs compatible with Apple Silicon from the outside.

For libraries that are Fat Architecture Binary,
we can change them from arm64 and x86_64-simulator to arm64 and arm64-simulator
and build them with arm64-Xcode and run them on arm64-simulator.
You can build it with arm64-Xcode and run it on arm64-simulator.

This tool can be recommended for projects that for some reason cannot support the xcframework,
or where changing the packaging of the library would increase the man-hours.

Input File Description
- linking: type `static` or `dynamic`.
- path: relative path, Source Root define `root` option.

"""
[
    {
        "linking": "dynamic",
        "path":  "relative/path/to/library"
    },
    {
        "linking": "static",
        "path":  "relative/path/to/framework/in/library"
    },
]
"""

USAGE: ranasa <config-file> [--root <root>] [--store <store>] [--minos <minos>] [--sdk <sdk>] [--xcode] [--simulator] [--thin] [--verbose] [--check]

ARGUMENTS:
  <config-file>           Path of the definition file

OPTIONS:
  -r, --root <root>       The location to root the library  (default: .)
  -s, --store <store>     The location to store save the binary (default: ${HOME}/.ranasa)
  --minos <minos>         Simulator minos variable number, default = 13.0
  --sdk <sdk>             Simulator sdk variable number, default = 13.0
  -x, --xcode             If in xcode script, auto detect simulator or actual. fall back to `simulator` flag.
  -a, --simulator         Replace binaries with simulator builds
  -t, --thin              Output builds to arm64_simulator architecture only
  -v, --verbose           Log detailed info to standard output.
  -c, --check             Display how ranasa recognizes the descriptions in the configuration file.
        Does not cause side effects. Only outputs the configuration file.
  -h, --help              Show help information.
```

### Example

Define the required information in a json file.

```json
[
    {
        "linking": "dynamic",
        "path":  "relative/path/to/library"
    },
    {
        "linking": "static",
        "path":  "relative/path/to/framework/in/library"
    },
]
```

Run `Ranasa` with Xcode build script.
`Ranasa` will reference SDKROOT and automatically place a suitable binary.

```shell
ranasa -x <setting.json>
```


## Committers

Main Author: [@arasan01](https://github.com/arasan01)

Supported: [DMM.com](https://inside.dmm.com/)

## Maintenance

This application was originally created by [@arasan01](https://github.com/arasan01) for use within the iOS development team at DMM.com, and has been converted to OSS.
Therefore, maintenance will be performed while @arasan01 is involved in development at DMM.com.

If you want to continue to use it, please propose a formal fork location in an issue, and we will list the location in the README.


## Contribute

Please propose it in a Pull Request or Issue.

## License

Copyright 2021 DMM.com LLC.
Licensed under the MIT License.

## Recruiting

DMM.com is stepping up recruitment of mobile app developers.

Would you like to develop at DMM.com with us?

Feel free to talk to us if you're interested!

DMM.com Engineer Recruitment

https://dmm-corp.com/recruit/engineer/

## Documents

The readme has been machine translated in full at DeepL.

Please refer to Readme_ja.md for the original text.
