require 'json'
require 'authentic'

class Api::V1::ApiKeysController < ApplicationController
  respond_to :json
  include Api::V1::Authentic

  protect_from_forgery with: :null_session
  before_filter :restrict_access, :only=>[:reset]

  def reset
    old_key = @api_key.access_token
    @api_key.destroy
    @api_key = @api_user.api_keys.create

    payload = {
      "prepared_at"=>Time.now,
      "old_token"=>old_key,
      "token"=>@api_key.access_token,
      "key_expires"=>@api_key.expires
    }

    render json: payload.to_json

  end
end
