# ReqRoom

ReqRoom is a light weight backend framework for building views and controllers, parsing and routing HTTP requests, rendering templates, and protecting against CSRF attacks.

## ControllerBase

**ControllerBase** serves as the parent class for all of the controllers in the app.

### render_content(content, content_type)
Sets the response object's `content_type` and `body`
Sets an instance variable `@already_built_response` to ensure that content is not rendered twice.

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
## Session

**Session** allows you to set cookies with client information that persists even if the user closes the browser, switches tabs, or navigates to a different page on the site.

It uses the Rack Library to set cookies  and get cookies:

`Rack::Request#cookies` returns a hash like object which you can then use to set data.
`Rack::Response#set_cookie` allows you to add that data to the responses cookies.

## Router

**Router** matches a `Rack::Request` object's path with a route and then runs the appropriate method in that route's controller.

### draw(&proc)
Takes a proc which instantiates which routes will be available.

```ruby
router.draw do
  post Regexp.new('/search/(?<podcast>\w+)'), PodcastsController, :search
end
# creates route objects from method calls in proc
%i(get post put delete).each do |http_method|
  define_method(http_method) do |pattern, controller_class, action_name|
    routes << Route.new(pattern, method, controller_class, action_name)
  end
end
```

### run(request, response)
Takes in a request and checks if there are any routes that match the request method and path.

## Route

### run
Sets the route params based on the request path and the route pattern, creates a new instance of its controller class, and invokes the appropriate action.

```ruby
def run(req, res)
  route_params = {}
  match_data = pattern.match(req.path)
  match_data.names.each do |key|
    route_params[key] = match_data[key]
  end
  controller = controller_class.new(req, res, route_params)
  controller.invoke_action(action_name)
end
```
