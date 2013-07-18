require 'socket'

class MiniUnicorn
  NUM_WORKERS = 12
  WORKER_PIDS = []
  
  def initialize(port = 8080)
    # socket(2)
    @listener = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)

    # bind(2)
    @listener.bind(Socket.sockaddr_in(8080, '0.0.0.0'))

    # listen(2)
    @listener.listen(512)

    # or use this...
    # TCPServer.new(8080)
  end

  def start
    # require rails
    # require bundler
    # require app
    
    NUM_WORKERS.times do
      WORKER_PIDS << Process.fork {
        worker_loop
      }
    end

    Process.waitall
  end

  def worker_loop
    #loop do
      # accept(2)
      client, _ = @listener.accept

      # IO.read() reads until EOF
      # readpartial() greedy
      # read() is lazy
      request = client.read

      # parse request
      # call Rack
     
      client.write "HTTP/1.1 200 OK\r\n"
      client.write "\r\n"
      client.write "Content-Type: text/plain\r\n"
      client.write "Content-Length: 3\r\n"
      client.write "\r\n"
      client.write "Hi!"
      client.write "\r\n\r\n"

      client.close
    #end
  end
end

uni = MiniUnicorn.new
uni.start

