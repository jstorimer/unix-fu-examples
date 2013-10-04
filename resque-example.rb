class LongSlowJob
  def self.perform
    # does the heavy lifting
    puts "phew, that was heavy"
  end
end

# Resque.enqueue(LongSlowJob)
# rake jobs:work

class MiniResque
  def self.reserve
    LongSlowJob
  end

  def self.work(strategy = :inproc)

    case strategy
    when :inproc
      # bloat by 5kb
      # x 5000 jobs/min
      # 25000kb / min
      
      job = reserve
      job.perform

    when :forking
      loop do
        # baseline
        
        child_pid = fork do
          100.times do
            job = reserve

            # bloat by 5MB
            job.work
            
            # implicit exit
            # all of its memory is cleaned up
          end
        end

        Process.waitpid(child_pid)
      end
    end
  end
end

