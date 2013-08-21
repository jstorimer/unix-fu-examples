class LongSlowJob
  def self.perform
    # do the heavy lifting
    puts "phew, that was tough"
  end
end

# Resque.enqueue(LongSlowJob)

class MiniResque
  def self.reserve
    # pretend this is popped from Redis
    LongSlowJob
  end

  def self.work_one_job(strategy)
    case strategy
    when :inproc
      job = reserve
      job.perform

      # bloat
      # 1kb
      # 5000 jobs/min

    when :forking
      # pristine state
      
      pid = fork {
        50.times {
          job = reserve
          job.perform
        }
        # exit
      }
      
      Process.wait(pid)
    end
  end
end

MiniResque.work_one_job(:inproc)
MiniResque.work_one_job(:forking)

