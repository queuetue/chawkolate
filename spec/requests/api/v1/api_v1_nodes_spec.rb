require 'spec_helper'

describe "Api::V1::Nodes" do

  it "fails without token" do
    get api_v1_node_last_path(node_id:"test:path")
    response.status.should be(401)
  end

  it "fails with a bad token" do
    get api_v1_node_last_path(node_id:"test:path"), nil, :authorization => %{Token token="foo"}
    response.status.should be(401)
  end

  it "passes with a real token" do
    u = FactoryGirl.create :user
    get api_v1_node_last_path(node_id:"test:path"), nil, :authorization => %{Token token="#{u.api_client_id}/#{u.api_keys.first.access_token}"}
    response.status.should be(200)
  end

  it "wont add empty items" do
    u = FactoryGirl.create :user
    post api_v1_node_add_points_path(node_id:"test:path"), nil, :authorization => %{Token token="#{u.api_client_id}/#{u.api_keys.first.access_token}"}
    response.status.should be(200)
    expect(response.body).to include "payload::data can not be empty."
  end

  it "will add items" do
    u = FactoryGirl.create :user
    post api_v1_node_add_points_path(node_id:"test:path"), {:payload=>'{"data":5}'}, {:authorization => %{Token token="#{u.api_client_id}/#{u.api_keys.first.access_token}"}}
    response.status.should be(200)
    expect(response.body).to include '"length":1'
    expect(response.body).to include '"v":5'
    post api_v1_node_add_points_path(node_id:"test:path"), {:payload=>'{"data":10}'}, {:authorization => %{Token token="#{u.api_client_id}/#{u.api_keys.first.access_token}"}}
    expect(response.body).to include '"length":2'
    expect(response.body).to include '"v":10'
  end

  it "will decrement" do
    u = FactoryGirl.create :user
    post api_v1_node_add_points_path(node_id:"test:path"), {:payload=>'{"data":5}'}, {:authorization => %{Token token="#{u.api_client_id}/#{u.api_keys.first.access_token}"}}
    expect(response.body).to include '"v":5'
    put api_v1_node_decrement_path(node_id:"test:path"), {:payload=>'{"data":1}'}, {:authorization => %{Token token="#{u.api_client_id}/#{u.api_keys.first.access_token}"}}
    response.status.should be(200)
    expect(response.body).to include '"v":4'
  end

  it "will increment" do
    u = FactoryGirl.create :user
    post api_v1_node_add_points_path(node_id:"test:path"), {:payload=>'{"data":5}'}, {:authorization => %{Token token="#{u.api_client_id}/#{u.api_keys.first.access_token}"}}
    expect(response.body).to include '"v":5'
    put api_v1_node_increment_path(node_id:"test:path"), {:payload=>'{"data":1}'}, {:authorization => %{Token token="#{u.api_client_id}/#{u.api_keys.first.access_token}"}}
    response.status.should be(200)
    expect(response.body).to include '"v":6'
  end

  it "will clear" do
    u = FactoryGirl.create :user
    post api_v1_node_add_points_path(node_id:"test:path"), {:payload=>'{"data":5}'}, {:authorization => %{Token token="#{u.api_client_id}/#{u.api_keys.first.access_token}"}}
    expect(response.body).to include '"v":5'
    put api_v1_node_clear_path(node_id:"test:path"), nil, {:authorization => %{Token token="#{u.api_client_id}/#{u.api_keys.first.access_token}"}}
    response.status.should be(200)
    payload = JSON.parse(response.body)
    payload.keys.length.should be 2  # addr + prepared_at
  end

end


     # api_v1_node_statistics GET      /api/v1/nodes/:node_id/statistics(.:format) api/v1/nodes#statistics
     #       api_v1_node_last GET      /api/v1/nodes/:node_id/last(.:format)       api/v1/nodes#last
     #      api_v1_node_since GET      /api/v1/nodes/:node_id/since(.:format)      api/v1/nodes#since
     #      api_v1_node_range GET      /api/v1/nodes/:node_id/range(.:format)      api/v1/nodes#range
     #                        DELETE   /api/v1/nodes/:id(.:format)                 api/v1/nodes#destroy