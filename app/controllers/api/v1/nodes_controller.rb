require 'json'
require 'authentic'

class Api::V1::NodesController < ApplicationController
  respond_to :json

  protect_from_forgery with: :null_session
  before_filter :restrict_access
  before_filter :restrict_access_by_key, :only=>[:last,:range, :since,:add_points,:increment,:decrement,:clear,:statistics]

  include Api::V1::Authentic

  def clear
    @node.points.destroy_all
    render json:{
      "node"=>@node.key,
      "prepared_at"=>Time.now
    }   
  end

  def increment
    if @node.points.length > 0
      value = JSON.parse(params[:payload])["data"]
      @node.increment value, {:meta=>do_meta}
      payload_out 
    else
      payload_out nil,"Can't increment an empty series."
    end
  end

  def decrement
    if @node.points.length > 0
      value = JSON.parse(params[:payload])["data"]
      @node.decrement value, {:meta=>do_meta}
      payload_out 
    else
      payload_out nil,"Can't decrement an empty series."
    end
  end

  def add_points
    if params[:payload] and params[:payload]["data"] and params[:payload]["data"].length > 0
      payload = JSON.parse(params[:payload])["data"]
      @node.add_points payload, {:meta=>do_meta}
      payload_out
    else
      payload_out nil, "payload::data can not be empty."
    end
  end

  def statistics
    payload_out
  end

  def last
    if @node.points.length > 0
      i = 0
      payload_out @node.points.last(1000).collect {|point| point_for_transport point,i+=1}
    else
      payload_out
    end
  end

  def range
    if params[:from] and params[:to] 
      points = @node.points.where("observed_at >=? and observed_at <=?",params[:from], params[:to])
      if points.length > 0
        i = 0
        payload_out points.collect {|point| point_for_transport point,i+=1}
      else
        payload_out
      end
    else
      payload_out( nil, "from and to are not valid")
    end
  end

  def since
    if params[:from]
      points = @node.points.where("observed_at >=? and observed_at <=?",params[:from], Time.now.to_f)
      if points.length > 0
        i = 0
        payload_out points.collect {|point| point_for_transport point,i+=1}
      else
        payload_out
      end
    else
      payload_out( nil, "from is not valid")
    end
  end

private

  def publish(data)
    key = "/node/#{@node.key}:change"
      logger.info "publish #{key} - #{data}"
    Redis.new.publish(key , {"data"=>data}.to_json)
  end

  def do_meta
    if params[:meta]
      meta = JSON.parse(params[:meta])
    else
      meta = {}
    end

    if meta["source"]
      meta["source"] = meta["source"] + "/" + "chawkolate_api_v_" + Rails.application.app_version
    else
      meta["source"] = "chawkolate_api_v_" + Rails.application.app_version
    end
    meta
  end

  def point_for_transport(point, index=nil)
    {"v"=>point.value,"t"=>point.observed_at,"m"=>JSON.parse(point.meta || "{}")}.merge(index ? {"i"=>index} : {})
  end

  def payload_out (data = nil,message = nil)
    payload = {
      "node"=>@node.key,
      "prepared_at"=>Time.now,
      "key_expires"=>@api_key.expires
    }

    if message
      payload["message"] = message
    end

    if data and data.length > 0
      payload["data"] = data
    end

    if @node.points.length == 0
      payload["last"]={"v"=>nil,"t"=>nil,"m"=>"{}"}
      payload["max"]=nil
      payload["min"]=nil
    else
      @last = @node.points.last
      last_items = point_for_transport(@last)
      payload["last"]=last_items
      payload["max"]=@node.max
      payload["min"]=@node.min
      payload["length"] = @node.points.length
    end
    publish payload

    render json: payload
  end

  def restrict_access_by_key
    begin
      @node = Chawk.node(@api_user.agent, params[:node_id])
    rescue ArgumentError => e
      head :unauthorized
    end
  end

end
