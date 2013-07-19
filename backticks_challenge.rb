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
  # TODO: implement me
end

if my_backticks('echo foobar') != 'foobar'
  raise 'hell'
end

def my_popen2(cmd)
  # TODO: implement me if you can!
end

