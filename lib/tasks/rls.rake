# frozen_string_literal: true

Rake::Task['db:load_config'].enhance(['rls:disable_rls_role'])

namespace :rls do
  def connection
    @connection ||= RLS.connection
  end

  task disable_rls_role: :environment do
    RLS.disable_rls_role!
  end

  task enable_rls_role: :environment do
    RLS.enable_rls_role!
  end

  task create_role: :environment do
    RLS.disable_rls_role!

    RLS.connection.execute <<~SQL
      CREATE ROLE "#{RLS.role}" WITH NOLOGIN;
      GRANT ALL ON ALL TABLES IN SCHEMA public TO "#{RLS.role}";
      GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO "#{RLS.role}";
    SQL

    puts "Role #{RLS.role} created"

    RLS.enable_rls_role!
  end

  task drop_role: :environment do
    RLS.disable_rls_role!

    RLS.connection.execute <<~SQL
      REVOKE ALL ON ALL TABLES IN SCHEMA public FROM "#{RLS.role}";
      REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM "#{RLS.role}";
      DROP OWNED BY "#{RLS.role}";
      DROP ROLE "#{RLS.role}";
    SQL

    puts "Role #{RLS.role} dropped"

    RLS.enable_rls_role!
  end

end
