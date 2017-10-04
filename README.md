# ReqRoom

ReqRoom is a light weight backend framework for building views and controllers, parsing and routing HTTP requests, rendering templates, and protecting against CSRF attacks.

## ControllerBase

**ControllerBase** serves as the parent class for all of the controllers in the app.

### #render_content(content, content_type)
Sets the response object's `content_type` and `body`
Sets an instance variable `@already_built_response` to ensure that content is not rendered twice.

### #redirect_to(url)
Sets the response location to the given url and sets the status to 302.

### #render(template_name)
Uses the controller and template names to construct paths to template files and creates a new ERB object to render.

```ruby
  def render(template_name)
    content = File.read("views/#{self.class.name.underscore}/" +
                        "#{template_name.to_s.underscore}.html.erb")
    new_content = ERB.new(content).result(binding)
    render_content(new_content, 'text/html')
  end
```

### CSRF Protection
Before serving a response to the user. ControllerBase validates the authenticity token in the request's cookies, ensuring that no sensitive information is served up to anyone other than the intended user.

```ruby
def invoke_action(action)
  if protect_from_forgery? && req.request_method != "GET"
    check_authenticity_token
  else
    form_authenticity_token
  end
  self.send(action)
  render(action) unless already_built_response?
end

def check_authenticity_token
  token = req.cookies["auth_token"]
  unless token && token == params["auth_token"]
    raise "Invalid authenticity token"
  end
end
```

## Session

**Session** allows you to set cookies with client information that persists even if the user closes the browser, switches tabs, or navigates to a different page on the site.

It uses the Rack Library to set cookies  and get cookies:

`Rack::Request#cookies` returns a hash like object which you can then use to set data.
`Rack::Response#set_cookie` allows you to add that data to the responses cookies.

## Route
Builds a route object with pattern, http_method, controller_class, and action_name instance variables.

### #run(request, response)
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
## Router

**Router** matches a `Rack::Request` object's path with a route and then runs the appropriate method in that route's controller.

### #draw(&proc)
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

### #run(request, response)
Takes in a request and checks if there are any routes that match the request_method and path, then calls `#run` on matching route.


## Flash
Builds a hash-like object from a given request, to store data that will only be available in the app's cookies for the current and next response cycle.

### #now
Values set in `flash.now` are only available in the current request cycle. Usually used to render an error when an action doesn't save:

```ruby
def create
  @user = User.find_by_credentials(params[:user][:username],params[:user][:password])
  if @user
    login(@user)
    render :show
  else
    flash.now[:error] = 'Invalid username/password combination'
    render :new
  end
end
```
### Middlewares

## ShowExceptions
Returns formatted error page showing the stack trace, a preview of the source code where the exception was raised and the exception message.

## Static
Serves static assets to the client side from the public directory.
