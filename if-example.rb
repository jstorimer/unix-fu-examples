# require rails
# require 100 gems
# 400 MB in memory
#
# fork - 400MB
# fork - 400MB
# fork - 400MB



@arr = Array(1..1000)

hosts = File.open('/etc/hosts')
puts "Pre-fork: hosts fileno is #{hosts.fileno}"

child_pid = fork do
  # exact copy
  
  # child process
  @arr.push(1001)
  puts "From child: @arr size is #{@arr.size}"

  puts "From child: hosts fileno is #{hosts.fileno}"
  hosts.close

  # implicit exit
end

# parent process
Process.waitpid(child_pid)
puts "From parent: @arr size is #{@arr.size}"
puts "From parent: hosts fileno is #{hosts.fileno}"

