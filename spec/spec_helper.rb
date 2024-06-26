# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require_relative "dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("dummy/db/migrate", __dir__)]

require "rspec/rails"
require "rake"
require "rls"

Rails.application.load_tasks

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before :suite do
    # ensure rls role and privileges are created
    Rake::Task["rls:create_role"].invoke
    Rake::Task["rls:create_role"].reenable
  end

  RSpec::Matchers.define_negated_matcher :not_change, :change
end
