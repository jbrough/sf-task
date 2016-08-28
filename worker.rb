require 'logger'

class Worker
  def initialize(redis)
    @log = Logger.new(STDOUT)
    @err = Logger.new(STDERR)

    @redis = redis
    @halted = false
  end

  def start(task)
    @redis.subscribe(:images) do |on|
      on.subscribe do |channel, _|
        @log.info("Subscribed to ##{channel}")
      end

      on.message do |_, _|
        if halted?
          @log.info('image added, resuming')
          @halt = false

          # this blocks receiving new messages until the loop exits,
          # which is ok since we'd ignore them anyway - but it's
          # still a hack.
          loop_jobs(task)
        end

      end

      loop_jobs(task)
    end
  end

  def halted?
    @halted
  end

  def halt
    @halted = true
    @log.info('halting waiting for jobs')
  end

  def loop_jobs(task)
    loop do
      job(task)
      break if @halted
    end
  end

  def job(task)
    location, err = task.next
    if err
      @err.error(err)
    elsif location
      @log.info(location)
    else
      halt
    end
  end
end
