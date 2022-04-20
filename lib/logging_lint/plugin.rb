# frozen_string_literal: true

module Danger
  # This danger plugin can be used to check log lines in modified (added) files. It heavily relies on regex
  # configuration which can be modified to search all kinds of parts of code in the files. Default configuration is set
  # to support Kotlin eMan Logger Library https://github.com/eManPrague/logger-ktx. Ex: logInfo { "Info message $var" }.
  #
  # It works in two steps. First it searches for all log lines (multilines) in files. And then it applies line variable
  # regex combined with line remove regex. Check [check_files] function for more information.
  #
  # @example Log linter with its basic configuration (searches for logInfo { "Message with $var" } and it's combinations)
  #
  #          logging_lint.log_lint
  #
  # @example Log linter with multiple log functions
  #
  #          # Linting multiple log functions
  #          logging_lint.log_functions = ["logInfo", "logWarn", "logError"]
  #          logging_lint.log_lint
  #
  # @example Log linter with completely custom functionality
  #
  #          # Linting only kotlin files (extensions without dot or star)
  #          logging_lint.file_extensions = ["kt"]
  #          # Linting multiple log functions
  #          logging_lint.log_functions = ["logInfo", "logWarn", "logError"]
  #          # Custom warning text and description
  #          logging_lint.warning_text = "You should really check this!"
  #          logging_lint.warning_description = "May be a security issue. Check this link: ...."
  #          # Custom log regex (searches for "foo $ bar")
  #          logging_lint.log_regex = '(\".*\$.*\")'
  #          # Custom log variable regex (searches for "$" and "${message}" in the log)
  #          logging_lint.line_variable_regex = ['\$', '${message}']
  #          # Custom log remove regex (removes nothing from the log lines)
  #          logging_lint.line_remove_regex = []
  #          # Marks start of the log when variable was found in it
  #          logging_lint.line_index_position = "start"
  #          logging_lint.log_lint
  #
  # @see eManPrague/danger-logging_lint
  # @tags log, logging, security, lint, kotlin
  #
  class DangerLoggingLint < Plugin
    DEFAULT_LOG_FUNCTIONS = %w(logInfo).freeze
    DEFAULT_LOG_REGEX = '[ ]?[{(](?:\n?|.)["]?(?:\n?|.)["]?(?:\n?|.)+(?:[)}][ ]?\n)'
    DEFAULT_LINE_VARIABLE_REGEX = ['[{(](\n| |\+)*([^\"]\w[^\"])+', '(\".*\$.*\")'].freeze
    DEFAULT_LINE_REMOVE_REGEX = ['(\+ )?\".*\"'].freeze
    DEFAULT_WARNING_TEXT = "Does this log comply with security rules?"

    #
    # File extensions are used to limit the number of files checked based on their extension. For example for Kotlin
    # language we want to check only .kt files and no other.
    #
    # This variable is optional. When it is not set the plugin will automatically check all files.
    #
    # @return [Array<String>] with file extensions
    #
    attr_accessor :file_extensions

    #
    # Warning description can be used to extend warning text. It can be used to provide more context for the log warning
    # such as more description, link with security rules and other.
    #
    # @return [String] with warning description
    #
    attr_accessor :warning_description

    #
    # Unfortunately due to line modification in function `contains_variable` it is not possible to accurately pinpoint
    # variable in the log. That is why there are three options for the offset to identity the line.
    #
    # Options are (set by `line_index_position`):
    # - "start" which means 0 offset and start of the log,
    # - "middle" which means length of the log divided by two,
    # - else ("end") which means length - 1 and end of the log. Used by default.
    #
    # @return [String] with line index position
    #
    attr_accessor :line_index_position

    #
    # Log functions are functions which define logging. They usually identify logging function that is being used. For
    # example logInfo, logWarn or logError. Each of these values is checked in a file combined with log_regex.
    #
    # @return [Array<String>] with log functions
    #
    attr_writer :log_functions

    #
    # Gets `log_functions` array from configuration or default `DEFAULT_LOG_FUNCTIONS` when null.
    #
    # @return [Array<String>] with log functions
    #
    def log_functions
      return DEFAULT_LOG_FUNCTIONS if @log_functions.nil?

      @log_functions
    end

    #
    # Warning text is used to modify the text displayed in the Danger report. It is a message with which the Danger
    # warning for specific log is created.
    #
    # @return [String] with warning text
    #
    attr_writer :warning_text

    #
    # Gets `warning_text` string from configuration or default `DEFAULT_WARNING_TEXT` when null.
    #
    # @return [String] with warning text
    #
    def warning_text
      return DEFAULT_WARNING_TEXT if @warning_text.nil?

      @warning_text
    end

    #
    # This regex is used to search for all log lines in a file. It does not check if there are variables in it. It just
    # searches for all logs. These results are used later to filter in them.
    #
    # @return [String] with log regex
    #
    attr_writer :log_regex

    #
    # Gets `log_regex` string from configuration or default `DEFAULT_LOG_REGEX` when null.
    #
    # @return [String] with log regex
    #
    def log_regex
      return DEFAULT_LOG_REGEX if @log_regex.nil?

      @log_regex
    end

    #
    # This regex is used to check log lines for variables. Since it is not always possible to find all variables using
    # one single regex it is represented as an array.
    #
    # This array cannot be null or empty for the script to function.
    #
    # @return [Array<String>] with regex array
    #
    attr_writer :line_variable_regex

    #
    # Gets `line_variable_regex` array from configuration or default `DEFAULT_LINE_VARIABLE_REGEX` when null or empty.
    #
    # @return [Array<String>] with regex array
    #
    def line_variable_regex
      return DEFAULT_LINE_VARIABLE_REGEX if @line_variable_regex.nil? || @line_variable_regex.size <= 0

      @line_variable_regex
    end

    #
    # This regex is used to clear the log line before variable regex is applied. It allows us to clear values that would
    # interfere with variable searching.
    #
    # This array cannot be null but it can be empty for this script to function.
    #
    # @return [Array<String>] with regex array
    #
    attr_writer :line_remove_regex

    #
    # Gets `line_remove_regex` array from configuration or default `DEFAULT_LINE_REMOVE_REGEX` when null or empty.
    #
    # @return [Array<String>] with regex array
    #
    def line_remove_regex
      return DEFAULT_LINE_REMOVE_REGEX if @line_remove_regex.nil?

      @line_remove_regex
    end

    #
    # Triggers file linting on specific target files. But first it does few checks if it actually needs to run.
    # 1) Checks if `log_functions` have size at least 1. If they are not then this script send Danger fail and cancels.
    # 2) Checks if `line_variable_regex` have size at least 1. If they are not then this script send Danger fail and
    # cancels.
    # 3) Filters target files based on `file_extensions` and if there are no files to check it will send Danger message
    # and cancels.
    #
    # If all of these checks pass then it will trigger linter on target files (filtered) using `check_files`.
    #
    # @return [void]
    #
    def log_lint
      if log_functions.nil? || log_functions.size <= 0
        self.fail("No log functions are defined. Please check your Danger file.")
        return
      end

      if line_variable_regex.nil? || line_variable_regex.size <= 0
        message("At least one variable index must be defined (using default). Please check your Danger file.")
      end

      target_files = (git.modified_files - git.deleted_files) + git.added_files
      if !file_extensions.nil? && file_extensions.size >= 0
        file_extensions_regex = "(.#{file_extensions.join('|.')})"
        target_files = target_files.grep(/#{file_extensions_regex}/)
      end

      if target_files.empty?
        message("No files to check.")
        return
      end

      check_files(target_files)
    end

    #
    # Checks all files for log violations based on log regex and log function. Each log function id extended by log
    # regex and searched for (format: #log_function#log_regex). Each of such found line is then checked if it contains a
    # variable. If it does it is warned with a specific line index and warning text. Uses Danger warn level with sticky
    # option.
    #
    # @return [void]
    #
    def check_files(files)
      raw_file = ""
      files.each do |filename|
        raw_file = File.read(filename)
        log_functions.each do |log_function|
          raw_file.scan(/#{log_function}#{log_regex}/m) do |c|
            if contains_variable(c)
              char_index = $~.offset(0)[0] + line_offset(c)
              line_index = raw_file[0..char_index].lines.count
              warn(compose_warning_text(warning_text), true, filename, line_index)
            end
          end
        end
      end
    end

    #
    # Checks if log contains variable or not. Requires `line_variable_regex` variable to be configured. For each of this
    # regex is searches value in `line_remove_regex`. If it is found then it is used to replace parts of the log using
    # `gsub` function. It makes sure variable regex can be used on complex logs like `logInfo(\n"TEST"\n+ message\n)`.
    # After cleaning it will try to match the variable regex in modified log.
    #
    # @return [Boolean] true if contains regex else false
    #
    def contains_variable(log)
      line_variable_regex.each_with_index do |regex, index|
        next if regex.nil?

        log_temp = log
        remove_regex = line_remove_regex[index]
        unless remove_regex.nil?
          log_temp = log.gsub(/#{remove_regex}/, "")
        end
        return true if log_temp.match?(regex)
      end
      false
    end

    #
    # Calculates line offset which is used to identify line to danger. Unfortunately due to line modification in
    # `contains_variable` it is not possible to accurately pinpoint variable in the log. That is why there are three
    # options for the offset to identity the line.
    #
    # Options are (set by `line_index_position`):
    # - "start" which means 0 offset and start of the log,
    # - "middle" which means length of the log divided by two,
    # - else ("end") which means length - 1 and end of the log.
    #
    # @return [Integer] offset based on `line_index_position` and line length
    #
    def line_offset(line)
      case line_index_position
      when "start"
        0
      when "middle"
        (line.length - 1) / 1
      else
        line.length - 1
      end
    end

    #
    # Composes warning text. If `warning_description` is defined it will return a combination with `warning_text` else
    # it will return only `warning_text`.
    #
    # @return [String] with warning text (and description)
    #
    def compose_warning_text(warning_text)
      return warning_text if warning_description.nil?

      "#{warning_text} Check: #{warning_description}"
    end
  end
end
