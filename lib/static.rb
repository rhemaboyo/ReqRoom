require 'byebug'
require 'mime/types'

class Static
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    path = "public/#{req.path.match(/(?<=\/public\/).+/)}"
    response(path)
  end

  def response(path)
    res = Rack::Response.new
    if File.exist?(path)
      ext = path.match(/\.\w+\.?/)[0].chomp('.')
      res['Content-type'] = MIME::Types.type_for(ext)[0].to_s
      res.write(File.read(path))
    else
      res.status = 404
      res.write('cannot find file')
    end
    res.finish
  end
end
