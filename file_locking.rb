lockfile = File.open('my_lockfile')

if lockfile.flock(File::LOCK_EX | File::LOCK_NB)
  # you got it
  # do the work
  sleep
else
  puts "This task is already running"
end

