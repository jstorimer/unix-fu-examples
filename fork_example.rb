@arr = Array(1..1000)

hosts = File.open('/etc/hosts')
puts hosts.fileno

# require rails
# require gems
# require app
#
# 500MB

# 1 * 500MB = 500MB

pid = fork do
  # HERE
  # everything is shared
  
  puts hosts.fileno
  hosts.close
  
  @arr.delete(1000)
  puts @arr.size
  # exit
end

Process.wait(pid)
puts @arr.size
puts hosts.closed?

