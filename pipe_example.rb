reader, writer = IO.pipe
# 1 writer open

reader.write('foo')

pid = fork {
  # 2 writers open
  reader.close
  writer.write('Hi parent')
  # exit
  # writer.close
}
# 1 writer open

writer.close
# 0 writers open

Process.wait(pid)
puts reader.readpartial(512)

# IO#read is a lazy read
#   blocks until EOF

# IO#readpartial is a greedy read
#   reads as much as it can immediately


