require 'rack'

require_relative 'task_handler'

map '/next' do
  run TaskHandler.new
end
