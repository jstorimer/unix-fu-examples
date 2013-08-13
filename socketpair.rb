require 'socket'

#s1, s2 = Socket.pair(Socket::AF_UNIX, Socket::SOCK_STREAM)
sock1, sock2 = UNIXSocket.pair(:STREAM)

fork {
  sock1.close

  size_of_I = [42].pack('I').size

  while packed_size = sock2.read(size_of_I)
    data_size = packed_size.unpack('I').first
    data = sock2.read(data_size)

    sock2.write(data.reverse)
  end
}

sock2.close

palindromes = ['race car', 'satire veritas']

palindromes.each do |data|
  sock1.write([data.size].pack('I'))
  sock1.write(data)
end

palindromes.each do |data|
  puts sock1.read(data.size)
end

