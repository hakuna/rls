module RLS
  module Migration

    def rls_tenant_table(table_name, column: :tenant_id, role: RLS.role, &block)
      reversible do |dir|
        dir.up do
          execute <<~SQL
            ALTER TABLE "#{table_name}" ENABLE ROW LEVEL SECURITY;
            CREATE POLICY "#{table_name}_#{role}" ON "#{table_name}" TO "#{role}" USING ("#{column}" = (current_setting('rls.tenant_id', FALSE)::bigint));
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
