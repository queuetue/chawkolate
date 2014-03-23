require 'json'

class EventController < ApplicationController
	include ActionController::Live

  # Don't use this in development mode without turning 
  # threading back on, or it WILL lock up on you.

  def listen  
    response.headers["Content-Type"] = "text/event-stream"
    redis = Redis.new

    key = "/node/#{params[:event_id]}:change"
    logger.info "listen #{key}"
    redis.subscribe(key) do |on|
      on.message do |event, data|
      response.stream.write "event: update\n"
      response.stream.write "data: "+data+"\n\n"
      end
    end

  rescue IOError  
    # Client disconnected
  ensure  
    response.stream.close
  end  

end
