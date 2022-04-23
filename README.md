## Logging Lint
[![Gem Version](https://badge.fury.io/rb/danger-logging_lint.svg)](https://badge.fury.io/rb/danger-logging_lint) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/eManPrague/danger-logging_lint/blob/master/LICENSE.txt) [![Test](https://github.com/eManPrague/danger-logging_lint/actions/workflows/test.yml/badge.svg)](https://github.com/eManPrague/danger-logging_lint/actions/workflows/test.yml) [![codecov](https://codecov.io/gh/eManPrague/danger-logging_lint/branch/master/graph/badge.svg?token=Z2RZKYNBVI)](https://codecov.io/gh/eManPrague/danger-logging_lint)

This danger plugin can be used to check log lines in modified (added) files. It heavily relies on regex configuration which can be modified to search all kinds of parts of code in the files. Default configuration is set to support [Kotlin eMan Logger Library](https://github.com/eManPrague/logger-ktx). Ex: logInfo { "Info message $var" }.

It works in two steps. First it searches for all log lines (multilines) in files. And then it applies line variable regex combined with line remove regex. Check `check_files` function for more information.

## Installation

    $ gem install danger-logging_lint

## Usage

> Log linter with its basic configuration (searches for logInfo { "Message with $var" } and it's combinations)
> ```
> logging_lint.log_lint
> ```

> Log linter with multiple log functions
> ```
> # Linting multiple log functions
> logging_lint.log_functions = ["logInfo", "logWarn", "logError"]
> logging_lint.log_lint
> ```


> Log linter with completely custom functionality
> ```
> # Linting only kotlin files (extensions without dot or star)
> logging_lint.file_extensions = ["kt"]
> # Linting multiple log functions
> logging_lint.log_functions = ["logInfo", "logWarn", "logError"]
> # Custom warning text and description
> logging_lint.warning_text = "You should really check this!"
> logging_lint.warning_description = "May be a security issue. Check this link: ...."
> # Custom log regex (searches for "foo $ bar")
> logging_lint.log_regex = '(\".*\$.*\")'
> # Custom log variable regex (searches for "$" and "${message}" in the log)
> logging_lint.line_variable_regex = ['\$', '${message}']
> # Custom log remove regex (removes nothing from the log lines)
> logging_lint.line_remove_regex = []
> # Marks start of the log when variable was found in it
> logging_lint.line_index_position = "start"
> logging_lint.log_lint
> ```

### Attributes

`file_extensions` - File extensions are used to limit the number of files checked based on their extension. For example for Kotlin language we want to check only .kt files and no other.  
`log_functions` - Log functions are functions which define logging. They usually identify logging function that is being used. For example logInfo, logWarn or logError. Each of these values is checked in a file combined with log_regex.  
`warning_text` - Warning text is used to modify the text displayed in the Danger report. It is a message with which the Danger warning for specific log is created.  
`warning_description` - Warning description can be used to extend warning text. It can be used to provide more context for the log warning such as more description, link with security rules and other.  
`log_regex` - This regex is used to search for all log lines in a file. It does not check if there are variables in it. It just searches for all logs. These results are used later to filter in them.  
`line_variable_regex` - This regex is used to check log lines for variables. Since it is not always possible to find all variables using one single regex it is represented as an array. This array cannot be null or empty for the script to function.  
`line_remove_regex` - This regex is used to clear the log line before variable regex is applied. It allows us to clear values that would interfere with variable searching. This array cannot be null but it can be empty for this script to function.  
`line_index_position` - Unfortunately due to line modification in function `contains_variable` it is not possible to accurately pinpoint variable in the log. That is why there are three options for the offset to identity the line. Options are: "start", "middle", "end".

### Methods

`log_lint` - Triggers file linting on specific target files. But first it does few checks if it actually needs to run.
1) Checks if `log_functions` have size at least 1. If they are not then this script send Danger fail and cancels.
2) Checks if `line_variable_regex` have size at least 1. If they are not then this script send Danger fail and
cancels.
3) Filters target files based on `file_extensions` and if there are no files to check it will send Danger message
and cancels.

If all of these checks pass then it will trigger linter on target files (filtered) using `check_files`.

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.

## Deployment

Gem is deployed manually from master branch using [Github Action](https://github.com/eManPrague/danger-logging_lint/actions/workflows/deploy.yml). Make sure you increased the gem version before triggering it.
