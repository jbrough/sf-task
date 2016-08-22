require 'rack'
require_relative 'task'

class TaskHandler
  def call(env)
    buf = Task.next
    if buf == 0
      [200, {}, []]
    else
      headers = { 'Content-Type' => 'image/jpeg' }
      [200, headers, [buf]]
    end
  end
end
