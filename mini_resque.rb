class LongSlowJob
  def self.perform
    # do the heavy lifting
    puts 'phew, that was heavy...'
  end
end

# Resque.enqueue(LongSlowJob)
# $ rake jobs:work

class MiniResque
  
  def self.reserve
    # pretend we popped this from redis
    LongSlowJob
  end
  
  def self.work(approach = :inproc)

    case approach
    when :inproc
      job = reserve
      job.perform

    when :with_fork
      child_pid = fork {
        job = reserve
        job.perform
      }

      Process.waitpid(child_pid)

    end
  end
end

MiniResque.work(:inproc)
MiniResque.work(:with_fork)

