Signal.trap(:INT) {
  puts 'got int'

  Signal.trap(:INT, "IGNORE")
}

puts Process.pid
sleep

