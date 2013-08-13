require 'socket'

class Venti
  class Stream
    def initialize(client)
      @client = client
    end

    def on_readable(data)
      raise NotImplementedError
    end

    def write(data)
      begin
        bytes = to_io.write_nonblock(data)
        @pending = nil
      rescue Errno::EWOULDBLOCK
        rest = data[bytes..-1]
        @pending = rest
      end
    end

    def pending_write
      @pending
    end

    def pending_write?
      !!@pending
    end

    def to_io
      @client
    end
  end

  class Server
    def initialize(port, stream_class)
      @server = TCPServer.new(port)
      @streams = []
      @stream_class = stream_class
    end

    def tick
      
      monitor_for_reading = @streams + [@server]
      monitor_for_writing = @streams.select(&:pending_write?)

      ready = IO.select(monitor_for_reading, monitor_for_writing)

      # just work with stuff that's readable
      readables = ready[0]
      writables = ready[1]

      readables.each do |readable|
        if readable == @server
          # handle the server case
          
          begin
            client = @server.accept_nonblock
            stream = @stream_class.new(client)

            @streams << stream
          rescue Errno::EWOULDBLOCK
          end

        else
          # handle the client case
          begin
            data = readable.to_io.read_nonblock(4096)
            readable.on_readable(data)
          rescue Errno::EWOULDBLOCK
          rescue Errno::EOFError
            readable.close
            @streams.delete(stream)
          end
        end
      end

      writables.each do |writables|
        writable.write(writable.pending_write)
      end
    end

    def start
      loop { tick }
    end
  end
end









class EchoStream < Venti::Stream
  def on_readable(data)
    write(data)
  end
end

serv = Venti::Server.new(3355, EchoStream)
serv.start

