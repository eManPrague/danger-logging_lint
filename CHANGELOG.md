## Changelog

### Version 0.0.5 (TBD)

### Version 0.0.4 (2022-04-28)

- Fixed crash when changed file is a directory (filters them out).
- Fixed crash when opening missing file (filters them out).
- Split rspec into multiple files.
- Added tests for linter with all variables set using Danger file.
- Variables used in multiple tests are defined as constants in `spec_helper.rb`.

### Version 0.0.3 (2022-04-22)

- Added deploy and test yaml for github workflow.
- Added deployment to Readme.
- Added codecov connection and dependency.
- Added Readme badges.
- Remove "Check: " hardcoded ext from warning message.
- Fixed tests.
- Updated Gemfile.lock.

### Version 0.0.2 (2022-04-21)

- Updated `gemspec` (gem) documentation.
- Fixed warning call.
- Changed test checks to use `violation_report` instead of `status_report`.

### Version 0.0.1 (2022-04-20)

- Initial version of the library.