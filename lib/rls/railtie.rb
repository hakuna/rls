# frozen_string_literal: true

module RLS
  class Railtie < Rails::Railtie
    config.rls = ActiveSupport::OrderedOptions.new
    config.rls.global_models = []
    config.rls.db_user = 'app_user'

    config.to_prepare do
    end

    rake_tasks do
      load "tasks/rls.rake"
    end
  end
end
