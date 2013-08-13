
# Process.daemon

def daemonize
  # Let the child process continue, exit the parent.
  exit if fork
  # inherited fds

  # Create a new session, become the session leader process,
  # Create a process group and become the leader.
  # No longer affected if the parent process group is killed.
  Process.setsid

  # no longer a session leader, or a group leader.
  # leaders *can* possibly be hooked up to terminals.
  exit if fork

  # Any other directory might disappear or be unmounted.
  Dir.chdir("/")

  STDIN.reopen("/dev/null")
  STDOUT.reopen("/dev/null")
  STDERR.reopen("/dev/null")
end

daemonize

# write pidfile
# reopen std streams

