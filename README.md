# ReqRoom

ReqRoom is a light weight backend framework for building views and controllers, parsing and routing HTTP requests, rendering templates, and protecting against CSRF attacks.

## ControllerBase

**ControllerBase** serves as the parent class for all of the controllers in the app.

### render_content(content, content_type)
Sets the response object's `content_type` and `body`and sets an instance variable, `@already_built_response`, to ensure that content is not rendered twice.

### redirect_to(url)
Sets the response location to the given url and sets the status to 302.

### render(template_name)
Uses the controller and template names to construct paths to template files and creates a new ERB object to render.

```ruby
  def render(template_name)
    content = File.read("views/#{self.class.name.underscore}/" +
                        "#{template_name.to_s.underscore}.html.erb")
    new_content = ERB.new(content).result(binding)
    render_content(new_content, 'text/html')
  end
```
### Session

**Session** allows you to set cookies with client information that persists even if the user closes the browser, switches tabs, or navigates to a different page on the site.

It uses the Rack Library to set cookies  and get cookies:

`Rack::Request#cookies` returns a hash like object which you can then input data into and add the the responses cookies with `Rack::Response#set_cookie`.
