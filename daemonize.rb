
def daemonize
  exit if fork
  
  # no longer connected to the login(1) shell session
  # no longer part of any process group connected to the shell
  Process.setsid

  # ensures that the daemon process is not a leader (session or pg)
  exit if fork

  # Any other directory might be deleted or unmounted.
  Dir.chdir('/')

  $stdin.reopen('/dev/null')
  $stdout.reopen('/dev/null')
  $stderr.reopen('/dev/null')
end

daemonize
sleep

