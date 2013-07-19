class LongSlowJob
  def self.perform
    # does lots of work
    puts "phew, done"
  end
end

# put it on redis
# Resque.enqueue(LongSlowJob)

# rake jobs:work

class MiniResque
  def self.reserve
    LongSlowJob
  end

  def self.work(strategy)

    case strategy
    when :inproc
      # 1kb / job
      # 1000 jobs / min
      # 1MB / min
      job = reserve
      job.perform
    when :fork
      child_pid = fork {
        # 10MB / job

        50.times {
          job = reserve
          job.perform
        }

        # exit
      }

      Process.waitpid(child_pid)
    end

  end
end

MiniResque.work(:inproc)
MiniResque.work(:fork)

