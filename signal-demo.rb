Signal.trap(:INT) do
  puts "got INT"
  puts "Deleting first file..."
  sleep 0.1 # simulate delete

  puts "Deleting second file..."
  sleep 0.1 #simulate delete

  exit
end

sleep

