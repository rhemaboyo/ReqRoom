require 'json'
require 'byebug'

class Session
  attr_reader :data
  # find the cookie for this app
  # deserialize the cookie into a data
  def initialize(req)
    @data = JSON.parse(req.cookies['_req_room_session']) rescue {}
  end

  def [](key)
    data[key]
  end

  def []=(key, val)
    data[key] = val
  end

  # serialize the data into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.set_cookie('_req_room_session', path: '/', value: data.to_json)
  end
end
