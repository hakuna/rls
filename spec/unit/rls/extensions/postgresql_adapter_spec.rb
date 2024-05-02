# frozen_string_literal: true

require "spec_helper"

RSpec.describe RLS::Extensions::PostgreSQLAdapter do
  class MyAdapter
    prepend RLS::Extensions::PostgreSQLAdapter

    def quote(str)
      "'#{str}'"
    end

    def execute(str)
      str
    end

    def clear_query_cache
      nil
    end
  end

  let(:connection) { MyAdapter.new }

  describe "#initialize" do
    it "sets the role" do
      expect_any_instance_of(MyAdapter).to receive(:execute).with("SET ROLE 'dummy_rls_test'")
      connection # initialize
    end

    context "when admin" do
      before { Thread.current[:rls_admin] = true }

      it "does not set the role" do
        expect_any_instance_of(MyAdapter).not_to receive(:execute).with("SET ROLE 'dummy_rls_test'")
        connection # initialize
      end
    end
  end

  describe "#rls_set" do
    it "sets the tenant_id" do
      expect(connection).to receive(:execute).with("SET rls.tenant_id = '123'")
      connection.rls_set(tenant_id: "123")
    end
  end

  describe "#rls_reset" do
    it "resets the tenant_id" do
      expect(connection).to receive(:execute).with("RESET rls.tenant_id")
      connection.rls_reset
    end

    it "clears the query cache" do
      expect(connection).to receive(:clear_query_cache)
      connection.rls_reset
    end
  end
end
