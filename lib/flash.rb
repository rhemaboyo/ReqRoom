require 'json'

class Flash
  attr_reader :now, :later

  def initialize(req)
    @now = JSON.parse(req.cookies['_rec_room_session']) rescue {}
    @later = {}
  end

  def [](key)
    now[key.to_s] || later[key.to_s]
  end

  def []=(key, val)
    later[key.to_s] = val
  end

  def store_flash(res)
    res.set_cookie('_rec_room_session', path: '/', value: later.to_json)
  end
end
