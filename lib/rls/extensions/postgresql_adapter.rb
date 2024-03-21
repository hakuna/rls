module RLS
  module Extensions
    module PostgreSQLAdapter
      def initialize(...)
        super

        unless RLS.admin
          puts "SET ROLE #{RLS.role}"
          execute("SET ROLE #{RLS.role}")
        else
          puts "NO ROLE"
        end
      end
    end
  end
end
