# frozen_string_literal: true

load_config_task = Rake::Task['db:load_config']
load_config_task.enhance(['rls:switch_to_migration_user'])

namespace :rls do
  task switch_to_migration_user: :environment do
    ActiveRecord::Base.configurations = ActiveRecord::Base.configurations.configurations.map do |cfg|
      ActiveRecord::DatabaseConfigurations::HashConfig.new(cfg.env_name, cfg.name, cfg.configuration_hash.merge(
        username: cfg.configuration_hash.fetch(:migration_username, cfg.configuration_hash[:username]),
      ))
    end

    ActiveRecord::Base.establish_connection
  end
end
