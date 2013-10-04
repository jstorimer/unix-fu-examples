child_pid = fork {
}

sleep 2
result = Process.waitpid(child_pid, Process::WNOHANG)
p result
