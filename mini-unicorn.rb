require 'socket'

class MiniUnicorn
  NUM_WORKER = 5
  WORKER_PIDS = []
  SIGNAL_QUEUE = []
  SIGNAL_WE_CARE_ABOUT = [:INT, :QUIT, :USR2]
  SELF_PIPE_READER, SELF_PIPE_WRITER = IO.pipe

  def initialize(port = 8080)
    @listener = TCPServer.new(port)
  end

  def start
    # load_app
    set_program_name
    spawn_workers
    trap_signals

    loop do
      IO.select([SELF_PIPE_READER])
      SELF_PIPE_READER.read(1) # clean out the pipe

      case SIGNAL_QUEUE.shift
      when :INT
        WORKER_PIDS.each do |wpid|
          Process.kill(:INT, wpid)
        end

        sleep 1
        WORKER_PIDS.each do |wpid|
          unless Process.waitpid(wpid, Process::WNOHANG)
            Process.kill(:KILL, wpid)
          end
        end

        exit

      when :USR2
        reexec
      end
    end
  end

  def reexec
    puts "Going for hot restart..."

    fork {
      exec "ruby", "mini-unicorn.rb"
    }
  end

  def set_program_name
    $PROGRAM_NAME = 'MiniUnicorn (Parent)'
  end

  def spawn_workers
    NUM_WORKER.times do |num|
      spawn_worker(num)
    end
  end

  def trap_signals
    SIGNAL_WE_CARE_ABOUT.each do |sig|
      Signal.trap(sig) do
        SIGNAL_QUEUE << sig
        SELF_PIPE_WRITER.write('.')
      end
    end
  end

  def spawn_worker(num)
    WORKER_PIDS << Process.fork {
      $PROGRAM_NAME = "MiniUnicorn (Worker ##{num})"

      Signal.trap(:INT) {
        # gracefully finish the current request and then exit
        exit
      }

      worker_loop
    }

  end

  def worker_loop
    loop do
      client, _ = @listener.accept

      data = client.readpartial(512)
      client.write(data)
      client.close
    end
  end
end

server = MiniUnicorn.new
server.start

