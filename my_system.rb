def my_system(cmd)
  pid = fork {
    begin
      exec(cmd)
    rescue Errno::ENOENT
      exit 1
    end
  }

  pid, status = Process.wait2(pid)
  status.success?
end

system_return_value = system('dontexist')
my_system_return_value = my_system('dontexist')

p system_return_value
p my_system_return_value


