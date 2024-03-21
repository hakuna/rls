module RLS
  module Migration

    # RESET rls.tenant_id will not remove the setting, current_setting(missing_ok=FALSE) will still return ''
    # There is no way to remove a setting right now in PostgreSQL, so missing_ok=FALSE is not useful
    # https://stackoverflow.com/questions/50923911/how-to-remove-configuration-parameter/50929568#50929568
    def rls_tenant_table(table_name, column: :tenant_id, role: RLS.role, &block)
      reversible do |dir|
        dir.up do
          execute <<~SQL
            ALTER TABLE "#{table_name}" ENABLE ROW LEVEL SECURITY;
            CREATE POLICY "#{table_name}_#{role}" ON "#{table_name}" TO "#{role}"
              USING ("#{column}" = NULLIF(current_setting('rls.tenant_id', TRUE), '')::bigint);
          SQL
        end
        dir.down do
          execute <<~SQL
            DROP POLICY "#{table_name}_#{role}" ON "#{table_name}";
            ALTER TABLE "#{table_name}" DISABLE ROW LEVEL SECURITY;
          SQL
        end
      end
    end

  end
end
