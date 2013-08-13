@arr = Array(1..10_000)


# require rails
# require gems
# require app
#
# 10.times do
#   fork {
#     # handle connections
#   }
# end

null = File.open('/dev/null')
puts null.fileno

pid = Process.fork {
  puts null.fileno
  puts null.write('foo')

  null.close
  puts @arr.size
}

Process.waitpid(pid)

puts @arr.size
puts null.closed?
