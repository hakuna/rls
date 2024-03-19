# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Postgresql adapter extension integration" do
  before do
    RLS.create("tenant1")
    RLS.create("tenant2")

    RLS.switch!("tenant1")
    Post.create!(title: "Tenant1: Foo")
    Post.create!(title: "Tenant1: Bar")

    RLS.switch!("tenant2")
    Post.create!(title: "Tenant2: Hello World")
  end

  after do
    RLS.drop("tenant1")
    RLS.drop("tenant2")
  end

  let(:connection) { ActiveRecord::Base.connection }

  describe "#execute" do
    specify do
      RLS.switch! "tenant1"
      result = connection.execute("SELECT * FROM posts")
      expect(result.cmd_tuples).to eq 2
      expect(result).to be_all { |row| row["title"].include?("Tenant1") }

      RLS.switch! "tenant2"
      result = connection.execute("SELECT * FROM posts")
      expect(result.cmd_tuples).to eq 1
      expect(result).to be_all { |row| row["title"].include?("Tenant2") }
    end
  end

  describe "#exec_query" do
    specify do
      RLS.switch! "tenant1"

      result = connection.exec_query("SELECT * FROM posts", "SQL", [], prepare: false)
      expect(result.rows.count).to eq 2
      result = connection.exec_query("SELECT * FROM posts", "SQL", [], prepare: false, tenant: "tenant2")
      expect(result.rows.count).to eq 1
      result = connection.exec_query("SELECT * FROM posts", "SQL", [], prepare: false)
      expect(result.rows.count).to eq 2
    end
  end

  context "with connection reset" do
    it "keeps the schema search path" do
      RLS.switch! "tenant1"

      result = connection.execute("SELECT * FROM posts")
      expect(result.cmd_tuples).to eq 2

      # connection reset resets schema
      connection.reset!

      result = connection.execute("SELECT * FROM posts")
      expect(result.cmd_tuples).to eq 2
    end
  end

  context "with outside mingling" do
    it "keeps the schema search path" do
      RLS.switch! "tenant1"

      result = connection.execute("SELECT * FROM posts")
      expect(result.cmd_tuples).to eq 2
      expect(result).to be_all { |row| row["title"].include?("Tenant1") }

      connection.schema_search_path = "\"tenant2\""

      result = connection.execute("SELECT * FROM posts")
      expect(result.cmd_tuples).to eq 2
      expect(result).to be_all { |row| row["title"].include?("Tenant1") }
    end
  end


end
