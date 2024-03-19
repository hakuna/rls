# frozen_string_literal: true

require "spec_helper"

RSpec.describe "load_async support (Rails 7.0+)", if: Rails::VERSION::MAJOR >= 7 do
  before do
    self.use_transactional_tests = false

    # ensure dummy app uses thread pool for load_async
    expect(Rails.application.config.active_record.async_query_executor).to eq :global_thread_pool

    RLS.create("acme")
    RLS.create("umbrella-corp")
  end

  after do
    RLS.drop("acme")
    RLS.drop("umbrella-corp")
  end

  it "supports async retrieval of posts" do
    RLS.switch!("acme")

    Post.create!(title: "ACME1")
    Post.create!(title: "ACME2")

    expect(Post.count).to eq 2

    RLS.switch!("umbrella-corp")
    post = Post.create!(title: "GVirus")

    expect(Post.count).to eq 1
    result = Post.slow.load_async
    expect(result).to be_scheduled

    # now switch to other tenant
    RLS.switch!("acme")

    # wait for result, ensure async query was executed
    # within correct tenant schema
    res = result.to_a
    expect(res.count).to eq 1
    expect(res).to eq [post]
  end
end
