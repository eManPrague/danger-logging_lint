# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)

module Danger
  describe Danger::DangerLoggingLint do
    it "should be a plugin" do
      expect(Danger::DangerLoggingLint.new(nil)).to be_a Danger::Plugin
    end

    #
    # Defines linter, danger file and other variables used by the linter.
    #
    describe "with Dangerfile" do
      before do
        @dangerfile = testing_dangerfile
        @logging_lint = @dangerfile.logging_lint

        allow(@logging_lint.git).to receive(:deleted_files).and_return([])
        allow(@logging_lint.git).to receive(:added_files).and_return([])
        allow(@logging_lint.git).to receive(:modified_files).and_return([])
        allow(@logging_lint).to receive(:file_extensions).and_return(%w(kt))
        allow(@logging_lint).to receive(:log_functions).and_call_original
        allow(@logging_lint).to receive(:warning_text).and_call_original
        allow(@logging_lint).to receive(:log_regex).and_call_original
        allow(@logging_lint).to receive(:line_variable_regex).and_call_original
        allow(@logging_lint).to receive(:line_remove_regex).and_call_original
      end

      #
      # Test for logging lines in cases when linter does run.
      #

      it "Nothing is printed when log functions are not present in files" do
        allow(@logging_lint.git).to receive(:modified_files).and_return(MODIFIED_FILES)
        allow(@logging_lint.git).to receive(:added_files).and_return(ADDED_FILES)
        allow(@logging_lint).to receive(:log_functions).and_return(%w(unknownLogLevel))
        @logging_lint.log_lint
        expect(@dangerfile.status_report[:warnings]).to eq([])
      end

      it "Log with variables is warned for modified files (end line index)" do
        allow(@logging_lint.git).to receive(:modified_files).and_return(MODIFIED_FILES)
        allow(@logging_lint).to receive(:line_index_position).and_return("end")
        @logging_lint.log_lint
        violation_lines = [63, 64, 73, 76, 88, 92, 97, 98, 101, 106, 107, 110]
        compare_warning_with_lines(violation_lines)
      end

      it "Log with variables is warned for modified files (start line index)" do
        allow(@logging_lint.git).to receive(:modified_files).and_return(MODIFIED_FILES)
        allow(@logging_lint).to receive(:line_index_position).and_return("start")
        @logging_lint.log_lint
        violation_lines = [63, 64, 71, 74, 85, 89, 93, 98, 99, 102, 107, 108]
        compare_warning_with_lines(violation_lines)
      end

      it "Log with variables is warned for modified files (middle line index)" do
        allow(@logging_lint.git).to receive(:modified_files).and_return(MODIFIED_FILES)
        allow(@logging_lint).to receive(:line_index_position).and_return("middle")
        @logging_lint.log_lint
        violation_lines = [63, 64, 73, 76, 88, 92, 97, 98, 101, 106, 107, 110]
        compare_warning_with_lines(violation_lines)
      end

      it "Log with variables is warned for new files" do
        allow(@logging_lint.git).to receive(:added_files).and_return(ADDED_FILES)
        @logging_lint.log_lint
        violation_lines = [47, 48, 57, 60, 72, 76]
        compare_warning_with_lines(violation_lines)
      end

      it "Log with variables is warned for new files (with all params)" do
        custom_warning_text = "Warning text"
        allow(@logging_lint.git).to receive(:added_files).and_return(ADDED_FILES)
        @logging_lint.log_functions = %w(logInfo)
        @logging_lint.warning_text = custom_warning_text
        @logging_lint.log_regex = '[ ]?[{(](?:\n?|.)["]?(?:\n?|.)["]?(?:\n?|.)+(?:[)}][ ]?\n)'
        @logging_lint.line_variable_regex = ['[{(](\n| |\+)*([^\"]\w[^\"])+', '(\".*\$.*\")']
        @logging_lint.line_remove_regex = ['(\+ )?\".*\"']
        @logging_lint.log_lint
        violation_lines = [47, 48, 57, 60, 72, 76]
        compare_warning_with_lines(violation_lines)
        expect(@dangerfile.violation_report[:warnings][0].message).to eq(custom_warning_text)
      end

      #
      # Compares violation lines against danger warning lines. It expects them to be equal.
      #
      def compare_warning_with_lines(violation_lines)
        warnings = @dangerfile.violation_report[:warnings]
        warning_lines = warnings.map(&:line)
        expect(warning_lines).to eq(violation_lines)
      end
    end
  end
end
