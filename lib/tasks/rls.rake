# frozen_string_literal: true

# disable before
Rake::Task['db:load_config'].enhance(['rls:disable'])

# enable after
Rake::Task.tasks.each do |task|
  if task.prerequisites.any? { |pre| pre == 'db:load_config' || (pre == 'load_config' && task.name.start_with?('db:')) }
    task.enhance do
      Rake::Task['rls:enable'].invoke
    end
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
    RLS.disable!

    RLS.connection.execute <<~SQL
      CREATE ROLE "#{RLS.role}" WITH NOLOGIN;
      GRANT ALL ON ALL TABLES IN SCHEMA public TO "#{RLS.role}";
      GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO "#{RLS.role}";
      ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO "#{RLS.role}";
      ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO "#{RLS.role}";
    SQL

    puts "Role #{RLS.role} created"

    RLS.enable!
  end

  task drop_role: :environment do
    RLS.disable!

    RLS.connection.execute <<~SQL
      ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM "#{RLS.role}";
      ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON SEQUENCES FROM "#{RLS.role}";
      REVOKE ALL ON ALL TABLES IN SCHEMA public FROM "#{RLS.role}";
      REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM "#{RLS.role}";
      DROP OWNED BY "#{RLS.role}";
      DROP ROLE "#{RLS.role}";
    SQL

    puts "Role #{RLS.role} dropped"

    RLS.enable!
  end

end
