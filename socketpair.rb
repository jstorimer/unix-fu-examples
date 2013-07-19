require 'socket'

# UNIXServer.pair(:STREAM)
sock1, sock2 = Socket.socketpair(Socket::AF_UNIX, Socket::SOCK_STREAM)

fork {
  # owns socket2
  # reversal process

  sock1.close

  # 4 bytes
  size_of_I = [42].pack("I").size

  while packed_size = sock2.read(size_of_I)
    unpacked_size = packed_size.unpack("I").first

    data = sock2.read(unpacked_size)
    sock2.write(data.reverse)
  end
}

sock2.close

palindromes = ['race car', 'satire veritas']

palindromes.each do |data|
  sock1.write([data.size].pack("I"))
  sock1.write(data)
end

# netstring

palindromes.each do |p|
  puts sock1.read(p.length)
end

