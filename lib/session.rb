require 'json'
require 'byebug'

class Session
  attr_reader :hash
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    @hash = JSON.parse(req.cookies['_req_room_session']) rescue {}
  end

  def [](key)
    hash[key]
  end

  def []=(key, val)
    hash[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.set_cookie('_req_room_session', path: '/', value: hash.to_json)
  end
end
