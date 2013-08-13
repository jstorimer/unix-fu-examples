current_dir = Dir.pwd

Process.daemon

# reopen std streams
$stdout.reopen('/tmp/daemon_out.log')
$stderr.reopen('/tmp/daemon_err.log')

# write pidfile
pidfile = File.open(current_dir + '/unixfu.pidfile', 'w')
if pidfile.flock(File::LOCK_EX | File::LOCK_NB)
  pidfile.write(Process.pid)
  pidfile.flush
else
  abort "Already running..."
end

pipe = File.open('/tmp/unixfu.pipe')

loop do
  puts pipe.read
end

