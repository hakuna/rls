module RLS
  module Migration

    def rls_setup(role: RLS.role)
      reversible do |dir|
        dir.up do
          execute "DROP ROLE IF EXISTS #{role}"
          execute "CREATE ROLE #{role} WITH NOLOGIN"
          execute "GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO #{role}"
          execute "GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO #{role}"
        end
        dir.down do
          execute "REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM #{role}"
          execute "REVOKE SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public FROM #{role}"
          execute "DROP ROLE #{role}"
        end
      end
    end

    def rls_tenant_table(table_name, column: :tenant_id, role: RLS.role, &block)
      reversible do |dir|
        dir.up do
          execute "ALTER TABLE #{table_name} ENABLE ROW LEVEL SECURITY"
          execute "CREATE POLICY #{table_name}_#{role} ON #{table_name} TO #{role} USING (#{column} = (current_setting('rls.tenant_id', FALSE)::bigint))"
        end
        dir.down do
          execute "DROP POLICY #{table_name}_#{role} ON #{table_name}"
          execute "ALTER TABLE #{table_name} DISABLE ROW LEVEL SECURITY"
        end
      end
    end

  end
end
