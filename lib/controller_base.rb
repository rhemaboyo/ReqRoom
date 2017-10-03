require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require_relative './flash'
require 'active_support/inflector'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = req.params.merge(route_params)
  end

  def already_built_response?
    @already_built_response
  end

  def redirect_to(url)
    res.location = url
    res.status = 302
    session.store_session(res)
    flash.store_flash(@res)

    raise "double redirect" if already_built_response?
    @already_built_response = true
  end

  def render_content(content, content_type)
    res.write(content)
    res['Content-Type'] = content_type
    session.store_session(res)
    flash.store_flash(@res)

    raise "double render" if already_built_response?
    @already_built_response = true
  end

  def render(template_name)
    content = File.read("views/#{self.class.name.underscore}/" +
                        "#{template_name.to_s.underscore}.html.erb")
    new_content = ERB.new(content).result(binding)
    render_content(new_content, 'text/html')
  end

  def session
    @session ||= Session.new(req)
  end

  def flash
    @flash ||= Flash.new(req)
  end

  def invoke_action(action)
    if protect_from_forgery? && req.request_method != "GET"
      check_authenticity_token
    else
      set_authenticity_token
    end
    self.send(action)
    render(action) unless already_built_response?
  end

  def set_authenticity_token
    @auth_token ||= SecureRandom.urlsafe_base64(16)
    res.set_cookie('auth_token', path: '/', value: @auth_token)
    @auth_token
  end

  def check_authenticity_token
    token = @req.cookies["auth_token"]
    unless token && token == params["auth_token"]
      raise "Invalid authenticity token"
    end
  end

  def self.protect_from_forgery
    @@protect_from_forgery = true
  end

  def protect_from_forgery?
    @@protect_from_forgery
  end
end
