# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)

#
# Tests for situations when the linter does not run because of either configuration or there are no files to check.
#

module Danger
  describe Danger::DangerLoggingLint do
    #
    # Defines linter, danger file and other variables used by the linter.
    #
    describe "with Dangerfile" do
      before do
        @dangerfile = testing_dangerfile
        @logging_lint = @dangerfile.logging_lint

        mock_variables(@logging_lint)
      end

      #
      # Test for logging lines in cases when linter does not run (either by config or file settings).
      #

      it "Error is printed when log functions are not configured" do
        allow(@logging_lint).to receive(:log_functions).and_return([])
        @logging_lint.log_lint
        expect(@dangerfile.status_report[:errors]).to eq(["Logging lint: No log functions are defined. Please check your Danger file."])
      end

      it "Error is printed when log variable regex is not configured" do
        allow(@logging_lint).to receive(:line_variable_regex).and_return([])
        @logging_lint.log_lint
        expect(@dangerfile.status_report[:messages][0]).to eq("Logging lint: At least one variable index must be defined (using default). Please check your Danger file.")
      end

      it "Nothing is printed when there are no files to check" do
        @logging_lint.log_lint
        expect(@dangerfile.status_report[:errors]).to eq([])
        expect(@dangerfile.status_report[:messages][0]).to eq("Logging lint: No files to check.")
      end

      it "Nothing is printed when there are only folders to check" do
        allow(@logging_lint).to receive(:file_extensions).and_return([])
        allow(@logging_lint.git).to receive(:modified_files).and_return(%W(#{DIR_NAME}))
        @logging_lint.log_lint
        expect(@dangerfile.status_report[:errors]).to eq([])
      end

      it "Nothing is printed when there are no files to check (filtered by extensions)" do
        allow(@logging_lint.git).to receive(:modified_files).and_return(MODIFIED_FILES)
        allow(@logging_lint).to receive(:file_extensions).and_return(%w(unknownExtension))
        @logging_lint.log_lint
        expect(@dangerfile.status_report[:errors]).to eq([])
      end
    end
  end
end
