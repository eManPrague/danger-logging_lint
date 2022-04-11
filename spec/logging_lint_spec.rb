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

        modified_files = [File.read("#{File.dirname(__FILE__)}/fixtures/ModifiedFile.kt")]
        added_files = [File.read("#{File.dirname(__FILE__)}/fixtures/NewFile.kt")]

        allow(@logging_lint.git).to receive(:deleted_files).and_return([])
        allow(@logging_lint.git).to receive(:added_files).and_return(added_files)
        allow(@logging_lint.git).to receive(:modified_files).and_return(modified_files)
      end

      # Tests for logging in Kotlin files.

      it "Nothing is printed when log levels are missing" do
        allow(@logging_lint.git).to receive(:log_levels).and_return([])
        @logging_lint.lint
        expect(@dangerfile.status_report[:warnings]).to eq([])
      end

      it "Log with variables is warned" do
        allow(@logging_lint.git).to receive(:log_levels).and_return(["logInfo"])
        @logging_lint.lint
        warnings = @dangerfile.status_report[:warnings]
        expect(warnings.size).to eq(12)
        warnings.each do |warning|
          expect(warning).to eq("Does this log comply with security rules?")
        end
      end
    end
  end
end
