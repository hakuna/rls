# frozen_string_literal: true

load_config_task = Rake::Task['db:load_config']

# before task
load_config_task.enhance(['rls:enable_admin'])

# after task
load_config_task.enhance do
  load_config_task.enhance(['rls:disable_admin'])
end

namespace :rls do
  task enable_admin: :environment do
    RLS.admin = true
    ActiveRecord::Base.clear_all_connections!
    ActiveRecord::Base.establish_connection
  end

  task disable_admin: :environment do
    RLS.admin = true
    ActiveRecord::Base.clear_all_connections!
    ActiveRecord::Base.establish_connection
  end
end
