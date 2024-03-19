# frozen_string_literal: true

require_relative "rls/version"
require_relative "rls/railtie"
require_relative "rls/current"

module RLS
  class SchemaNotFound < StandardError; end
  class TenantNotSet < StandardError; end

  class << self
    def configure(&block)
      block.call(configuration)
    end

    def connection
      ActiveRecord::Base.connection
    end

    def configuration
      Rails.application.config.rls
    end

    def ensure_tenant_set!
      raise TenantNotSet unless current_tenant
    end

    def process(tenant, &block)
      raise "Please supply block" unless block_given?

      old_tenant = current_tenant
      self.current_tenant = tenant
      block.call
    ensure
      self.current_tenant = old_tenant
    end

    def switch!(tenant)
      self.current_tenant = tenant
    end

    def current_tenant
      RLS::Current.tenant
    end

    def exists?(tenant)
      connection.schema_exists?(tenant)
    end

    def import_default_schema(tenant)
      process(tenant) do
        load Rails.root.join("db/schema.rb")
      end
    end

    def seed(tenant)
      process(tenant) do
        load Rails.root.join("db/seeds.rb")
      end
    end

    def create(tenant)
      return false if exists?(tenant)

      connection.create_schema(tenant)
      import_default_schema(tenant)
      seed(tenant) if configuration.seed_after_create
      true
    end

    def drop(tenant)
      return false unless exists?(tenant)

      self.current_tenant = nil if current_tenant == tenant
      connection.drop_schema(tenant)
      true
    end

    def tenants
      configuration.tenants.respond_to?(:call) ? configuration.tenants.call : configuration.tenants
    end

    private

    def current_tenant=(tenant)
      raise SchemaNotFound, "Schema for tenant '#{tenant}' does not exist" if tenant && !exists?(tenant)

      RLS::Current.tenant = tenant
    end
  end
end
