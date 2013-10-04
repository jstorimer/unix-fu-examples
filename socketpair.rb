require 'socket'

parent_socket, child_socket = Socket.pair(Socket::AF_UNIX, Socket::SOCK_STREAM)

fork {
  # child_socket
  parent_socket.close

  size_of_I = [42].pack('I').size

  while packed_payload_size = child_socket.read(size_of_I)
    unpacked_payload_size = packed_payload_size.unpack('I').first
    payload = child_socket.read(unpacked_payload_size)

    child_socket.write(payload.reverse)
  end
}

child_socket.close

palindromes = ['race car', 'satire veritas']

palindromes.each do |payload|
  payload_size = [payload.size].pack('I')

  parent_socket.write(payload_size)
  parent_socket.write(payload)
end

palindromes.each do |data|
  puts parent_socket.read(data.size)
end


# race car
# 14satire veritas
# 145

