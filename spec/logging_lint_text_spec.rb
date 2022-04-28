# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)

#
# Tests for warning text creation. Text can contain description which can be defined in Danger file.
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
      # Test for waning text and description (optional).
      #

      it "Log with variables is warned description (link address)" do
        warning_description = "http://error.io"
        allow(@logging_lint.git).to receive(:added_files).and_return(ADDED_FILES)
        allow(@logging_lint).to receive(:warning_description).and_return(warning_description)
        @logging_lint.log_lint
        expect(@dangerfile.status_report[:warnings][0]).to eq("#{WARNING_TEXT} #{warning_description}")
      end

      it "Log with variables is warned without warning description" do
        allow(@logging_lint.git).to receive(:added_files).and_return(ADDED_FILES)
        @logging_lint.log_lint
        expect(@dangerfile.status_report[:warnings][0]).to eq(WARNING_TEXT)
      end
    end
  end
end
