module RLS
  module Extensions
    module PostgreSQLAdapter
      SET_ROLE_SQL = "SET ROLE %s".freeze

      SET_TENANT_ID_SQL = "SET rls.tenant_id = %s".freeze
      RESET_TENANT_ID_SQL = "RESET rls.tenant_id".freeze

      def initialize(...)
        super
        execute(format(SET_ROLE_SQL, quote(RLS.role))) unless RLS::Current.admin
      end

      def rls_set(tenant_id:)
        execute(format(SET_TENANT_ID_SQL, quote(tenant_id)))
      end

      def rls_reset
        execute(RESET_TENANT_ID_SQL)
        clear_query_cache
      end
    end
  end
end
