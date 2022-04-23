# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)

module Danger
  describe Danger::DangerLoggingLint do
    it "should be a plugin" do
      expect(Danger::DangerLoggingLint.new(nil)).to be_a Danger::Plugin
    end

    dir_name = File.dirname(__FILE__)
    modified_files = %W(#{dir_name}/fixtures/ModifiedFile.kt #{dir_name}/fixtures/IgnoredModifiedFile.txt)
    added_files = %W(#{dir_name}/fixtures/NewFile.kt)
    warning_text = "Does this log comply with security rules?"

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
      end

      #
      # Test for logging lines in cases when linter does not run (either by config or file settings).
      #

      it "Error is printed when log functions are not configured" do
        allow(@logging_lint).to receive(:log_functions).and_return([])
        @logging_lint.log_lint
        expect(@dangerfile.status_report[:errors]).to eq(["No log functions are defined. Please check your Danger file."])
      end

      it "Error is printed when log variable regex is not configured" do
        allow(@logging_lint).to receive(:line_variable_regex).and_return([])
        @logging_lint.log_lint
        expect(@dangerfile.status_report[:messages][0]).to eq("At least one variable index must be defined (using default). Please check your Danger file.")
      end

      it "Nothing is printed when there are no files to check" do
        @logging_lint.log_lint
        expect(@dangerfile.status_report[:errors]).to eq([])
      end

      it "Nothing is printed when there are folders to check" do
        allow(@logging_lint).to receive(:file_extensions).and_return([])
        allow(@logging_lint.git).to receive(:modified_files).and_return(%W(#{dir_name}))
        @logging_lint.log_lint
        expect(@dangerfile.status_report[:errors]).to eq([])
      end

      it "Nothing is printed when there are no files to check (filtered by extensions)" do
        allow(@logging_lint.git).to receive(:modified_files).and_return(modified_files)
        allow(@logging_lint).to receive(:file_extensions).and_return(%w(unknownExtension))
        @logging_lint.log_lint
        expect(@dangerfile.status_report[:errors]).to eq([])
      end

      it "Nothing is printed when log levels are not present" do
        allow(@logging_lint).to receive(:log_functions).and_return(%w(missingLogLevel))
        @logging_lint.log_lint
        expect(@dangerfile.status_report[:warnings]).to eq([])
      end

      #
      # Test for logging lines in cases when linter does run.
      #

      it "Log with variables is warned for modified files (end line index)" do
        allow(@logging_lint.git).to receive(:modified_files).and_return(modified_files)
        allow(@logging_lint).to receive(:line_index_position).and_return("end")
        @logging_lint.log_lint
        violation_lines = [63, 64, 73, 76, 88, 92, 97, 98, 101, 106, 107, 110]
        compare_warning_with_lines(violation_lines)
      end

      it "Log with variables is warned for modified files (start line index)" do
        allow(@logging_lint.git).to receive(:modified_files).and_return(modified_files)
        allow(@logging_lint).to receive(:line_index_position).and_return("start")
        @logging_lint.log_lint
        violation_lines = [63, 64, 71, 74, 85, 89, 93, 98, 99, 102, 107, 108]
        compare_warning_with_lines(violation_lines)
      end

      it "Log with variables is warned for modified files (middle line index)" do
        allow(@logging_lint.git).to receive(:modified_files).and_return(modified_files)
        allow(@logging_lint).to receive(:line_index_position).and_return("middle")
        @logging_lint.log_lint
        violation_lines = [63, 64, 73, 76, 88, 92, 97, 98, 101, 106, 107, 110]
        compare_warning_with_lines(violation_lines)
      end

      it "Log with variables is warned for new files" do
        allow(@logging_lint.git).to receive(:added_files).and_return(added_files)
        @logging_lint.log_lint
        violation_lines = [47, 48, 57, 60, 72, 76]
        compare_warning_with_lines(violation_lines)
      end

      #
      # Test for waning texts and links.
      #

      it "Log with variables is warned with link address" do
        warning_link = "http://error.io"
        allow(@logging_lint.git).to receive(:added_files).and_return(added_files)
        allow(@logging_lint).to receive(:warning_description).and_return(warning_link)
        @logging_lint.log_lint
        expect(@dangerfile.status_report[:warnings][0]).to eq("#{warning_text} #{warning_link}")
      end

      it "Log with variables is warned without link address" do
        allow(@logging_lint.git).to receive(:added_files).and_return(added_files)
        @logging_lint.log_lint
        expect(@dangerfile.status_report[:warnings][0]).to eq(warning_text)
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
