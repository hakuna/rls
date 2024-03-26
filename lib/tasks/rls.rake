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
      # Make sure query can be executed even if database in database.yml is not around yet
      ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).each do |config|
        config = config.configuration_hash.merge(database: "postgres", schema_search_path: "public")
        ActiveRecord::Base.establish_connection(config)

        ActiveRecord::Base.connection.execute <<~SQL
          DO $$
          BEGIN
            CREATE ROLE "#{RLS.role}" WITH NOLOGIN;
          EXCEPTION
            WHEN DUPLICATE_OBJECT THEN
              RAISE NOTICE 'Role "#{RLS.role}" already exists';
          END
          $$;

          GRANT ALL ON ALL TABLES IN SCHEMA public TO "#{RLS.role}";
          GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO "#{RLS.role}";
          ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO "#{RLS.role}";
          ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO "#{RLS.role}";
        SQL

        ActiveRecord::Base.connection.disconnect!
      end

      puts "Role #{RLS.role} created"
    end
  end

  task drop_role: :environment do
    RLS.without_rls do
      # Make sure query can be executed even if database in database.yml is not around yet
      ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).each do |config|
        config = config.configuration_hash.merge(database: "postgres", schema_search_path: "public")
        ActiveRecord::Base.establish_connection(config)

        ActiveRecord::Base.connection.execute <<~SQL
          ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM "#{RLS.role}";
          ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON SEQUENCES FROM "#{RLS.role}";
          REVOKE ALL ON ALL TABLES IN SCHEMA public FROM "#{RLS.role}";
          REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM "#{RLS.role}";
          DROP OWNED BY "#{RLS.role}";
          DROP ROLE "#{RLS.role}";
        SQL

        ActiveRecord::Base.connection.disconnect!
      end

      puts "Role #{RLS.role} dropped"
    end
  end

end
