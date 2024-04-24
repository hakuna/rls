module RLS
  module Extensions
    module SchemaDumper
      def tables(stream)
        super

        sql = <<~SQL
          SELECT policyname, tablename, cmd, permissive, roles, qual, with_check
            FROM pg_policies
            WHERE schemaname = 'public' AND qual LIKE '%rls.tenant_id%'
            ORDER BY tablename
        SQL

        @connection.execute(sql).each do |row|
          stream.puts "  rls_tenant_table \"#{row["tablename"]}\""
        end
      end
    end
  end
end
