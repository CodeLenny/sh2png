# Changelog

The format is based on [Keep a Changelog](http://keepachangelog.com/) 
and this project adheres to [Semantic Versioning](http://semver.org/).

Breaking changes are marked inline.
- :sos: **[breaking]** marks changes to functionality.
- :o: **[edge-case]** marks bug-fixes that correct improper output.  People depending on these bugs may have issues.
  In most cases, these changes will be versioned as minor releases.
- :unlock: **[internal]** marks changes to internal API methods that are marked `@private`.
  Users who override these methods might want to take these changes into account.
  In most cases, these changes will be versioned as minor releases.
- :cool: **[internal]** points out new internal features that developers building on-top of sh2png should be aware of.
  A change might add access to variables that would otherwise need to be hardcoded, or add extra utility methods.

## Unreleased

## Added
- `.editorconfig` to enforce basic lint rules
- CLI access via `sh2png` executable
- :cool: **[internal]** The default color scheme and key-code mapping is now available as a class variable

## Modified
- :o: **[edge-case]** Character widths were miscalculated.  This has been fixed,
  but output is slightly different.
