module Authentic

private

  def restrict_access
    @api_user = nil
    if current_user then
      @api_user = current_user
      true
    else
      authenticate_or_request_with_http_token do |token, options|
        id,key = token.split("/")
        api_user = User.find_by_api_client_id(id)
        unless api_user
          false
        else
          api_user.api_keys.each do |api_key|
            if api_key.active? and Devise.secure_compare(api_key.access_token,key)
              @api_key = api_key
              @api_user = api_user
              break
            end
          end
          !@api_user.nil?
        end
      end
    end
  end
end