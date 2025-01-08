# ⚙️ CLTLogger (**C**ommand-**L**ine **T**ools Logger)

<picture><img alt="Image Alt Text" src="https://img.shields.io/badge/Swift-6.0_%7C_5.10--5.2-blue"></picture>
<picture><img alt="Image Alt Text" src="https://img.shields.io/badge/Platforms-macOS_%7C_Linux_%7C_Windows_%7C_iOS_%7C_visionOS_%7C_tvOS_%7C_watchOS-blue"></picture>
[![](<https://img.shields.io/github/v/release/xcode-actions/clt-logger>)](<https://github.com/xcode-actions/clt-logger/releases>)

A simple [swift-log](<https://github.com/apple/swift-log>)-compatible logger designed for Command Line Tools.

## Usage

Bootstrap the LoggingSystem with CLTLogger before creating any logger:
```swift
LoggingSystem.bootstrap{ _ in CLTLogger() }

/* CLTLogger does not print the label of the logger, nor the date of the log by design.
 *
 * If you want these information in your log, you can add them using
 *  a metadata provider and metadata on the logger like so: */
LoggingSystem.bootstrap{ label in
   var ret = CLTLogger(metadataProvider: .init{ ["zz-date": "\(Date())"] })
   ret.metadata = ["zz-label": "\(label)"]
   return ret
}
```

## Metadata Log Format

The metadata log format is very opinionated:

- Everything is backslashed so as to be able to actually parse the metadata
directly from the output;
- But we assume level0 keys will never contain spaces, or any other weird chars,
and so we do not quote neither backslash level0 keys;
- Keys are sorted in the output, always.

Example of logs:
```text
⚠️ [request_id: "42"] with some metadata
⚠️ [request_id: "42", service_id: "ldap"] with some metadata
⚠️ [faulty_wires: "[\"d\", \"a\", \"oops, has\\\"a quote\"]", request_id: "42", service_id: "ldap"] with some metadata
```
