

puts Process.pid
gets
Process.daemon

# fork a child process and exit 
## the parent immediately
#exit if fork
#
## set up this in a new session
## sid = session id
##
## The current becomes the leader of a new process group
## The current becomes the leader of a new session group
##
## it's now free from the effects of the terminal
#Process.setsid
#
## without this, it's possible for the process to 
## reconnect to a terminal.
#exit if fork
#
## this may run for months or years
## most stable place to be
#Dir.chdir("/")
#
#$stdin.reopen('/dev/null')
#$stdout.reopen('/dev/null')
#$stderr.reopen('/dev/null')
#
## daemonization finished
#
## reopen std streams to logfiles
## writing a pidfile
#
File.open('silly.pid', 'w') do |f|
  f.write Process.pid.to_s
end

sleep

