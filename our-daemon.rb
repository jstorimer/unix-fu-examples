current_dir = Dir.pwd

Process.daemon

# now in the daemon process
# disconnected from standard terminal output

# redirect std streams
$stdout.reopen('/tmp/daemon_stdout.log')
$stderr.reopen('/tmp/daemon_stderr.log')

# write pidfile
pidfile = File.open(current_dir + '/unixfu.pidfile', 'r+')

if pidfile.flock(File::LOCK_EX | File::LOCK_NB)
  pidfile.rewind
  pidfile.write(Process.pid)
  pidfile.flush
else
  abort "It's already running..."
end

pipe = File.open('/tmp/unixfu.pipe', 'r')

loop do
  puts pipe.read
end

