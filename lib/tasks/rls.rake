# frozen_string_literal: true

Rake::Task.tasks.each do |task|
  task_name = task.name
  next unless task_name.start_with?("db:")

  # disable RLS role before running the task
  Rake::Task[task_name].enhance(["rls:disable"])

  # enable RLS role after running the task
  Rake::Task[task_name].enhance do
    Rake::Task["rls:enable"].invoke
  end

  # make sure they run again if multiple tasks are run
  Rake::Task[task_name].enhance do
    Rake::Task["rls:enable"].reenable
    Rake::Task["rls:disable"].reenable
  end
end

if Rails.env.test?
  Rake::Task["db:create"].enhance do
    Rake::Task["rls:create_role"].invoke
  end

  Rake::Task["db:drop"].enhance(["rls:drop_role"])
end

namespace :rls do
  def connection
    @connection ||= RLS.connection
  end

  task disable: :environment do
    RLS.disable!
  end

  task enable: :environment do
    RLS.enable!
  end

  task create_role: :environment do
    RLS.without_rls do
      ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).each do |db_config|
        ActiveRecord::Tasks::DatabaseTasks.with_temporary_connection(db_config) do |connection|
          connection.execute <<~SQL
            DO $$
            BEGIN
              IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '#{RLS.role}') THEN
                CREATE ROLE "#{RLS.role}" WITH NOLOGIN;
                RAISE NOTICE 'Role "#{RLS.role}" created';
              ELSE
                RAISE NOTICE 'Role "#{RLS.role}" already exists';
              END IF;
            END
            $$;

            GRANT ALL ON ALL TABLES IN SCHEMA public TO "#{RLS.role}";
            GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO "#{RLS.role}";
            ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO "#{RLS.role}";
            ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO "#{RLS.role}";
          SQL

          puts "Role #{RLS.role} created"
        end
      end
    end
  end

  task drop_role: :environment do
    RLS.without_rls do
      ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).each do |db_config|
        ActiveRecord::Tasks::DatabaseTasks.with_temporary_connection(db_config) do |connection|
          connection.execute <<~SQL
            ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM "#{RLS.role}";
            ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON SEQUENCES FROM "#{RLS.role}";
            REVOKE ALL ON ALL TABLES IN SCHEMA public FROM "#{RLS.role}";
            REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM "#{RLS.role}";
            DROP OWNED BY "#{RLS.role}";
            DROP ROLE "#{RLS.role}";
          SQL

          puts "Role #{RLS.role} dropped"
        end
      end
    end
  end

end
