class LongRunningJob
  def self.perform
    # do the heavy lifting
    puts 'phew, that was a lot'
  end
end

class MiniResque
  # gets the next job from redis
  def self.reserve
    LongRunningJob
  end

  def self.work
    loop do
      # loaded rails
      # laoded app
      child_pid = fork {
        50.times do
          job = reserve
          job.work
          #
        end
        
        # exit
      }

      Process.waitpid(child_pid)
    end
  end
end

