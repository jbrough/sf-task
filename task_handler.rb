require 'rack'
require_relative 'task'

class TaskHandler
  def call(env)
    req = Rack::Request.new(env)
    if !req.post?
      return [405, {}, ["Method Not Allowed"]]
    end

    location = Task.next
    if !location
      [204, {}, []]
    else
      headers = { 'Location' => location }
      [201, headers, []]
    end
  end
end
