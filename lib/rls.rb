# frozen_string_literal: true

require_relative "rls/current"
require_relative "rls/migration"
require_relative "rls/railtie"
require_relative "rls/version"

module RLS
  class << self
    SET_CUSTOMER_ID_SQL = "SET rls.tenant_id = %s".freeze
    RESET_CUSTOMER_ID_SQL = "RESET rls.tenant_id".freeze

    def configure(&block)
      block.call(configuration)
    end

    def connection
      ActiveRecord::Base.connection
    end

    def configuration
      Rails.application.config.rls
    end

    def role
      configuration.role
    end

    def enable!
      RLS::Current.admin = false
      ActiveRecord::Base.connection_pool.disconnect!
    end

    def disable!
      RLS::Current.admin = true
      ActiveRecord::Base.connection_pool.disconnect!
    end

    def without_rls(&block)
      raise "Please supply block" unless block_given?

      disable!
      block.call
    ensure
      enable!
    end

    def process(tenant_id, &block)
      raise "Please supply block" unless block_given?

      if tenant_id.present?
        set! tenant_id
      else
        reset!
      end

      block.call
    ensure
      reset!
    end

    def set!(tenant_id)
      connection.rls_set(tenant_id: tenant_id)
    end

    def reset!
      connection.rls_reset
    end

  end
end
