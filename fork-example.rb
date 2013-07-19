@arr = Array(1..5_000)

child_pid = Process.fork do
  # child process
  
  @arr.push(10)
  puts "Child @arr is #{@arr.size}"
  
  # implicit exit
end

Process.waitpid(child_pid)
puts @arr.size

