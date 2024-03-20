# frozen_string_literal: true
#
require_relative "extensions/postgresql_adapter"
require_relative "extensions/schema_dumper"

require "active_record/connection_adapters/postgresql_adapter"

module RLS
  class Railtie < Rails::Railtie
    config.to_prepare do
      ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(RLS::Extensions::PostgreSQLAdapter)
      ActiveRecord::ConnectionAdapters::PostgreSQL::SchemaDumper.prepend(RLS::Extensions::SchemaDumper)

      ActiveSupport::Inflector.inflections(:en) do |inflect|
        inflect.acronym "RLS"
      end

      ActiveRecord::Migration.include(RLS::Migration)
    end

    rake_tasks do
      load "tasks/rls.rake"
    end
  end
end
