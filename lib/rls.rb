# frozen_string_literal: true

require_relative "rls/version"
require_relative "rls/railtie"
require_relative "rls/current"

module RLS
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

    def process(tenant, &block)
      raise "Please supply block" unless block_given?

      old_tenant = RLS::Current.tenant
      RLS::Current.tenant = tenant
      block.call
    ensure
      RLS::Current.tenant = old_tenant
    end

    def switch!(tenant)
      RLS::Current.tenant = tenant
    end
  end
end
