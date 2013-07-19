require 'socket'

class Venti
  SIGNAL_QUEUE = []
  SELF_PIPE_READER, SELF_PIPE_WRITER = IO.pipe

  def initialize(port = 8080)
    @listener = TCPServer.new(port)
    @clients = []
  end

  def trap_signals
    [:USR1, :QUIT].each do |sig|
      Signal.trap(sig) {
        SIGNAL_QUEUE << sig

        begin
          SELF_PIPE_WRITER.write_nonblock('.')
        rescue Errno::EWOULDBLOCK
        end
      }
    end
  end

  def start
    trap_signals

    loop do
      select_for_reading = [@listener]
      select_for_reading.concat @clients
      select_for_reading << SELF_PIPE_READER

      ready = IO.select(select_for_reading)
      # [[@listener], [], []]

      if ready[0].delete(@listener)
        puts "got a new client!"
        @clients << @listener.accept
      end

      if ready[0].delete(SELF_PIPE_READER)
        case SIGNAL_QUEUE.shift
        when :QUIT
          puts "got QUIT"
        when :USR1
          puts "got USR1"
        end
      end

      ready[0].each do |client|
        begin
          data = client.read_nonblock(4096)
          client.write_nonblock(data)
        rescue Errno::EWOULDBLOCK
        rescue EOFError
          client.close
          @clients.delete(client)
        end
      end
    end
  end
end

server = Venti.new
server.start
