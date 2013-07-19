lock = File.open('lockfile', File::CREAT)

if lock.flock(File::LOCK_EX | File::LOCK_NB)
  # do the work
else
  # you didn't get the lock
  exit
end

