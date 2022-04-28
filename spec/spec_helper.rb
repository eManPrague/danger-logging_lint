# frozen_string_literal: true

require "simplecov"
SimpleCov.start

require "codecov"
SimpleCov.formatter = SimpleCov::Formatter::Codecov

require "pathname"
ROOT = Pathname.new(File.expand_path("..", __dir__))
$:.unshift("#{ROOT}lib".to_s)
$:.unshift("#{ROOT}spec".to_s)

require "bundler/setup"
require "pry"

require "rspec"
require "danger"

if `git remote -v` == ""
  puts "You cannot run tests without setting a local git remote on this repo"
  puts "It's a weird side-effect of Danger's internals."
  exit(0)
end

# Use coloured output, it's the best.
RSpec.configure do |config|
  config.filter_gems_from_backtrace "bundler"
  config.color = true
  config.tty = true
end

require "danger_plugin"

# These functions are a subset of https://github.com/danger/danger/blob/master/spec/spec_helper.rb
# If you are expanding these files, see if it's already been done ^.

# A silent version of the user interface,
# it comes with an extra function `.string` which will
# strip all ANSI colours from the string.

# rubocop:disable Lint/NestedMethodDefinition
def testing_ui
  @output = StringIO.new
  def @output.winsize
    [20, 9999]
  end

  cork = Cork::Board.new(out: @output)
  def cork.string
    out.string.gsub(/\e\[([;\d]+)?m/, "")
  end
  cork
end
# rubocop:enable Lint/NestedMethodDefinition

# Example environment (ENV) that would come from
# running a PR on TravisCI
def testing_env
  {
    "HAS_JOSH_K_SEAL_OF_APPROVAL" => "true",
    "TRAVIS_PULL_REQUEST" => "800",
    "TRAVIS_REPO_SLUG" => "artsy/eigen",
    "TRAVIS_COMMIT_RANGE" => "759adcbd0d8f...13c4dc8bb61d",
    "DANGER_GITHUB_API_TOKEN" => "123sbdq54erfsd3422gdfio"
  }
end

# A stubbed out Dangerfile for use in tests
def testing_dangerfile
  env = Danger::EnvironmentManager.new(testing_env)
  Danger::Dangerfile.new(env, testing_ui)
end

# Mocks linter variables. Should be called in "before" block.
def mock_variables(logging_lint)
  allow(logging_lint.git).to receive(:deleted_files).and_return([])
  allow(logging_lint.git).to receive(:added_files).and_return([])
  allow(logging_lint.git).to receive(:modified_files).and_return([])
  allow(logging_lint).to receive(:file_extensions).and_return(%w(kt))
  allow(logging_lint).to receive(:log_functions).and_call_original
  allow(logging_lint).to receive(:warning_text).and_call_original
  allow(logging_lint).to receive(:log_regex).and_call_original
  allow(logging_lint).to receive(:line_variable_regex).and_call_original
  allow(logging_lint).to receive(:line_remove_regex).and_call_original
end

# Defines test variables used in multiple text files.
DIR_NAME = File.dirname(__FILE__)
MODIFIED_FILES = %W(#{DIR_NAME}/fixtures/ModifiedFile.kt #{DIR_NAME}/fixtures/IgnoredModifiedFile.txt).freeze
ADDED_FILES = %W(#{DIR_NAME}/fixtures/NewFile.kt).freeze
WARNING_TEXT = "Does this log comply with security rules?"
