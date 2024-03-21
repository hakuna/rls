module RLS
  module Extensions
    module PostgreSQLAdapter
      def initialize(...)
        super
        enable_rls_role!
      end

      def enable_rls_role!
        execute("SET ROLE #{RLS.role}")
      end

      def disable_rls_role!
        execute("RESET ROLE")
      end
    end
  end
end
