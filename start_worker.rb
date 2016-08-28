require 'redis'

require_relative 'task'
require_relative 'worker'

client = Redis.new(url: ENV['SF_REDIS_HOST'])

worker = Worker.new(client)

worker.start(Task)
