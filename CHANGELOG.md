# Changelog

The format is based on [Keep a Changelog](http://keepachangelog.com/) 
and this project adheres to [Semantic Versioning](http://semver.org/).

Breaking changes are marked inline.
- **[breaking]** marks changes to functionality.
- **[edge-case]** marks bug-fixes that correct improper output.  People depending on these bugs may have issues.
  In most cases, these changes will be versioned as minor releases.
- **[internal]** marks changes to internal API methods that are marked `@private`.
  Users who override these methods might want to take these changes into account.
  In most cases, these changes will be versioned as minor releases.

## Unreleased

## Added
- `.editorconfig` to enforce basic lint rules
- CLI access via `sh2png` executable
- **[internal]** The default color scheme and key-code mapping is now available as a class variable

## Modified
- **[edge-case]** Character widths were miscalculated.  This has been fixed, but output is slightly different.
