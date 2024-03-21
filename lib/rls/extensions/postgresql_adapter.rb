module RLS
  module Extensions
    module PostgreSQLAdapter
      def initialize(...)
        super
        execute("SET ROLE #{RLS.role}") unless RLS.admin
      end
    end
  end
end
