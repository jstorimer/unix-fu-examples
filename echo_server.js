var net = require('net');
var fs = require('fs');

if (fs.existsSync('echo.sock'))
  fs.unlinkSync('echo.sock');

var server = net.createServer(function(conn) {
  console.log('client connected');

  conn.on('end', function() {
    console.log('client disconnected');
  });

  conn.on('data', function(data) {
    conn.write(data);
  });
});

server.listen('echo.sock', function() {
  console.log('server bound');
});

