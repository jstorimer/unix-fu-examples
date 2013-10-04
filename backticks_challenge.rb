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
  rd, wr = IO.pipe

  pid = fork {
    rd.close
    $stdout.reopen(wr)

    exec(cmd)
  }

  wr.close
  Process.wait(pid)

  rd.read
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
    stdin_writer.close
    stdout_reader.close

    $stdin.reopen(stdin_reader)
    $stdout.reopen(stdout_writer)
    exec(cmd)
  }

  stdin_reader.close
  stdout_writer.close

  yield stdin_writer, stdout_reader

  Process.wait(pid)
end

my_popen2('wc -w') do |stdin, stdout|
  stdin.write('How doth the little busy bee')
  stdin.close

  puts stdout.read
end


