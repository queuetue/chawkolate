require 'spec_helper'

describe "Api::V1::ApiKeys" do
  it "fails without token" do
    put reset_api_v1_api_key_path
    response.status.should be(401)
  end

  it "passes with a real token" do
    u = FactoryGirl.create :user
    put reset_api_v1_api_key_path, nil, :authorization => %{Token token="#{u.api_client_id}/#{u.api_keys.first.access_token}"}
    response.status.should be(200)
  end

  it "creates a new api key and disables current when reset" do
    u = FactoryGirl.create :user
    token = u.api_keys.first.access_token
    put reset_api_v1_api_key_path, nil, :authorization => %{Token token="#{u.api_client_id}/#{token}"}
    response.status.should be(200)
    payload = JSON.parse(response.body)
    payload["old_token"].should eq(token)
    payload["token"].should_not eq(token)
    new_token = payload["token"]
    put reset_api_v1_api_key_path, nil, :authorization => %{Token token="#{u.api_client_id}/#{new_token}"}
    response.status.should be(200)
    put reset_api_v1_api_key_path, nil, :authorization => %{Token token="#{u.api_client_id}/#{token}"}
    response.status.should be(401)
  end
end


