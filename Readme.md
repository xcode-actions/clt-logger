# CLTLogger
A simple SwiftLog-compatible logger designed for Command Line Tools.

## Usage
TODO

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
