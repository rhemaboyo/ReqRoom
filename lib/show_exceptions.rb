require 'erb'

class ShowExceptions
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    app.call(env)
  rescue RuntimeError => e
    render_exception(e)
  end

  private

  def render_exception(e)
    ['500', { 'Content-type' => 'text/html' }, [e.message]]
  end

end
