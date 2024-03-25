# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Posts", type: :request do
  let(:acme) { Tenant.create!(identifier: "acme") }
  let(:umbrella_corp) { Tenant.create!(identifier: "umbrella-corp") }

  it "limits posts to the tenant specified by the subdomain" do
    host! "acme.rls.test"
    post "/posts", params: { post: { title: "ACME Post", content: "This is content", tenant_id: acme.id} }
    expect(response).to have_http_status(:found)

    get "/posts"
    expect(response.body).to include("ACME Post")

    # switch tenant
    host! "umbrella-corp.rls.test"
    get "/posts"
    expect(response.body).not_to include("ACME Post")

    post "/posts", 
params: { post: { title: "New G-Virus", content: "This is classified information", tenant_id: umbrella_corp.id } }
    expect(response).to have_http_status(:found)

    get "/posts"
    expect(response.body).to include("New G-Virus")
    expect(response.body).not_to include("ACME Post")
  end
end
