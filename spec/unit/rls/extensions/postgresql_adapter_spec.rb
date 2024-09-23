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

    def configure_connection
      # noop
    end

    def clear_query_cache
      nil
    end
  end

  let(:connection) { MyAdapter.new }

  describe "#configure_connection" do
    subject { -> { connection.configure_connection } }

    it "sets the role" do
      expect_any_instance_of(MyAdapter).to receive(:execute).with("SET ROLE 'dummy_rls_test'")
      subject.call
    end

    context "when admin" do
      before { Thread.current[:rls_admin] = true }

      it "does not set the role" do
        expect_any_instance_of(MyAdapter).not_to receive(:execute).with("SET ROLE 'dummy_rls_test'")
        subject.call
      end
    end
  end

  describe "#rls_set" do
    subject { -> { connection.rls_set(tenant_id: "123") } }

    it "sets the tenant_id" do
      expect(connection).to receive(:execute).with("SET rls.tenant_id = '123'")
      subject.call
    end
  end

  describe "#rls_reset" do
    subject { -> { connection.rls_reset } }

    it "resets the tenant_id" do
      expect(connection).to receive(:execute).with("RESET rls.tenant_id")
      subject.call
    end

    it "clears the query cache" do
      expect(connection).to receive(:clear_query_cache)
      subject.call
    end
  end
end
