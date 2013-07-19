def my_system(cmd)
  child_pid = fork {
    begin
      exec(cmd)
    rescue Errno::ENOENT
      exit 1
    end
  }

  pid, status = Process.waitpid2(child_pid)
  status.success?
end

my_system('ls')
my_system('nonexistent_command')

