# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Postgresql adapter extension integration" do
  let(:connection) { ActiveRecord::Base.connection }

  specify do
    role = connection.query_value("SHOW ROLE")
    expect(role).to eq "dummy_rls_test"
  end

  context "when admin" do
    specify do
      Thread.current[:rls_admin] = true
      ActiveRecord::Base.connection_pool.disconnect!

      role = connection.query_value("SHOW ROLE")
      expect(role).to eq "none"

      # ensure we roll back for remaining specs
      Thread.current[:rls_admin] = false
      ActiveRecord::Base.connection_pool.disconnect!
    end
  end
end
