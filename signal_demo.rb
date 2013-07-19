
trap(:INT) do
  puts "got INT"
  File.delete('lockfile')
  exit
end

trap(:USR2) do
end

sleep
