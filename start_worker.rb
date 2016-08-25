require 'redis'

require_relative 'task'
require_relative 'worker'

client = Redis.new

worker = Worker.new(client)

worker.start(Task)
