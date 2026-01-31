ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Don't use fixtures - we create test data explicitly
    # fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

# Devise test helpers for system tests
class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
