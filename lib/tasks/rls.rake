# frozen_string_literal: true

load_config_task = Rake::Task['db:load_config']

# before task
load_config_task.enhance(['rls:disable_rls_role'])

# after task
load_config_task.enhance do
  Rake::Task['rls:enable_rls_role'].invoke
end

namespace :rls do
  task disable_rls_role: :environment do
    connection = ActiveRecord::Base.connection
    connection.disable_rls_role!
  end

  task enable_rls_role: :environment do
    connection = ActiveRecord::Base.connection
    connection.enable_rls_role!
  end
end
