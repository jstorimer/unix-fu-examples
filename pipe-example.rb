reader, writer = IO.pipe
# 1 writer instance, open

pid = fork do
  writer.write('Hello parent')
  # 2 writer instances, both open

  # implicit exit
  # child writer is closed
end

# writer.close

Process.wait(pid)

# read() - lazy, waits for EOF
# readpartial() - greedy
puts reader.readpartial(512)

# EOF terminates readpartial
# anything in the read buffer terminates readpartial

