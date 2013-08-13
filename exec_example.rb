
null = File.open('/dev/null')

# open database connections
# open logfiles
popen('imagemagick')

exec("NULL_FD=#{null.fileno} ruby -e \"puts IO.for_fd(ENV['NULL_FD'].to_i).fileno\"", {null.fileno => null})
# no more Ruby
puts 'after exec'

