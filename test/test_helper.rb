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

    # Assert all records of a model have a populated public_id matching prefix format
    def assert_all_backfilled(model_class)
      prefix = model_class.public_id_prefix
      pattern = /\A#{prefix}_[A-Za-z0-9]{8}\z/
      model_class.find_each do |record|
        assert record.public_id.present?, "#{model_class.name} ##{record.id} missing public_id"
        assert_match pattern, record.public_id, "#{model_class.name} ##{record.id} has invalid public_id: #{record.public_id}"
      end
    end
  end
end

# Devise test helpers for system tests
class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
