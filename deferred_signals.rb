SIGNAL_QUEUE = []

[:INT, :QUIT, :TERM].each do |sig|
  Signal.trap(sig) { SIGNAL_QUEUE << sig }
end

loop do
  case SIGNAL_QUEUE.shift
  when :INT
    puts 'sending signals...'
    sleep 2
    puts 'reaping children'
    exit
  when :QUIT
  when :TERM
  else
    # other housekeeping behaviour
    sleep 1
  end
end

