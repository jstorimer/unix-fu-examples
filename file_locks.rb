lock_file = File.open('mylockfile', 'w')

if lock_file.flock(File::LOCK_EX | File::LOCK_NB)
  puts 'got the lock'
  sleep
  # do the work
else
  # exit
end

