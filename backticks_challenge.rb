# Exercise 
# ========
# Implement #my_backticks to behave like the ` method in Ruby. 
# In other words, it should spawn the child process and return 
# whatever it prints to its $stdout.
#
# Hint: you'll need fork(2), exec(2), and pipe(2).
#
# Bonus challenge
# ===============
# If you get this one quickly, try implementing Open3.popen2().
# Hint: you'll need multiple pipes for this one.
#
# eg.
# Open3.popen2('wc -w') do |stdin, stdout|
#   stdin.write('How doth the little busy bee')
#   stdin.close
#   
#   puts stdout.read
# end

def my_backticks(cmd)
  reader, writer = IO.pipe

  pid = fork {
    reader.close

    $stdout.reopen(writer)
    exec(cmd)
  }

  Process.wait(pid)
  writer.close
  reader.read
end

if my_backticks('echo foobar') != "foobar\n"
  raise 'hell'
end

# Open3.popen2('wc -w') do |stdin, stdout|
#   stdin.write('How doth the little busy bee')
#   stdin.close
#   
#   puts stdout.read
# end

def my_popen2(cmd)
  stdin_reader, stdin_writer = IO.pipe
  stdout_reader, stdout_writer = IO.pipe

  pid = fork {
    $stdin.reopen(stdin_reader)
    $stdout.reopen(stdout_writer)

    exec(cmd)
  }

  stdout_writer.close
  stdin_reader.close

  yield stdin_writer, stdout_reader

  Process.wait(pid)
end

my_popen2('wc -w') do |stdin, stdout|
  stdin.write('How doth the little busy bee')
  stdin.close

  puts stdout.read
end


