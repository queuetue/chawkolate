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

  it "gives statistics" do
    u = FactoryGirl.create :user
    post api_v1_node_add_points_path(node_id:"test:path"), {:payload=>'{"data":5}'}, {:authorization => %{Token token="#{u.api_client_id}/#{u.api_keys.first.access_token}"}}
    expect(response.body).to include '"v":5'
    put api_v1_node_clear_path(node_id:"test:path"), nil, {:authorization => %{Token token="#{u.api_client_id}/#{u.api_keys.first.access_token}"}}
    response.status.should be(200)
    payload = JSON.parse(response.body)
    payload.keys.length.should be 2  # addr + prepared_at
  end

  it "gets last X" do
    u = FactoryGirl.create :user
    addr = Chawk.addr(u.agent,"test:path")
    addr.add_points [1,2,3,4,5,6,7,8,9,10]
    get api_v1_node_last_path(node_id:"test:path"), nil, :authorization => %{Token token="#{u.api_client_id}/#{u.api_keys.first.access_token}"}
    response.status.should be(200)
    payload = JSON.parse(response.body)
    payload["length"].to_i.should be(10)
  end

  it "gets range" do
    t= Time.now
    u = FactoryGirl.create :user
    addr = Chawk.addr(u.agent,"test:path")
    addr._insert_point(1,(t-1000).to_f)
    addr._insert_point(2,(t-1000).to_f)
    addr._insert_point(3,(t-1000).to_f)
    addr._insert_point(4,(t-400).to_f)
    addr._insert_point(5,(t-400).to_f)
    addr._insert_point(6,(t-400).to_f)

    get api_v1_node_last_path(node_id:"test:path"), nil, :authorization => %{Token token="#{u.api_client_id}/#{u.api_keys.first.access_token}"}
    response.status.should be(200)
    payload = JSON.parse(response.body)
    payload["length"].to_i.should be(6)

    get api_v1_node_range_path(node_id:"test:path",:from=>(t-1001).to_f, :to=>t.to_f), nil, :authorization => %{Token token="#{u.api_client_id}/#{u.api_keys.first.access_token}"}
    response.status.should be(200)
    payload = JSON.parse(response.body)
    payload["data"].length.should be(6)

    get api_v1_node_range_path(node_id:"test:path",:from=>(t-401).to_f, :to=>t.to_f), nil, :authorization => %{Token token="#{u.api_client_id}/#{u.api_keys.first.access_token}"}
    response.status.should be(200)
    payload = JSON.parse(response.body)
    payload["data"].length.should be(3)

    get api_v1_node_range_path(node_id:"test:path",:from=>(t-1001).to_f, :to=>(t-500).to_f), nil, :authorization => %{Token token="#{u.api_client_id}/#{u.api_keys.first.access_token}"}
    response.status.should be(200)
    payload = JSON.parse(response.body)
    payload["data"].length.should be(3)

  end

  it "gets since" do
    t= Time.now
    u = FactoryGirl.create :user
    addr = Chawk.addr(u.agent,"test:path")
    addr._insert_point(1,(t-1000).to_f)
    addr._insert_point(2,(t-1000).to_f)
    addr._insert_point(3,(t-1000).to_f)
    addr._insert_point(4,(t-400).to_f)
    addr._insert_point(5,(t-400).to_f)
    addr._insert_point(6,(t-400).to_f)


    get api_v1_node_since_path(node_id:"test:path",:from=>(t-1001).to_f), nil, :authorization => %{Token token="#{u.api_client_id}/#{u.api_keys.first.access_token}"}
    response.status.should be(200)
    payload = JSON.parse(response.body)
    payload["data"].length.should be(6)

    get api_v1_node_since_path(node_id:"test:path",:from=>(t-501).to_f), nil, :authorization => %{Token token="#{u.api_client_id}/#{u.api_keys.first.access_token}"}
    response.status.should be(200)
    payload = JSON.parse(response.body)
    payload["data"].length.should be(3)

    get api_v1_node_since_path(node_id:"test:path",:from=>(t-301).to_f), nil, :authorization => %{Token token="#{u.api_client_id}/#{u.api_keys.first.access_token}"}
    response.status.should be(200)
    payload = JSON.parse(response.body)
    payload["data"].should be(nil)

  end

end


     # api_v1_node_statistics GET      /api/v1/nodes/:node_id/statistics(.:format) api/v1/nodes#statistics
     #                        DELETE   /api/v1/nodes/:id(.:format)                 api/v1/nodes#destroy




