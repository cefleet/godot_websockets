//perMessageDeflate is imparative for some reason
var WebSocketServer = require('ws').Server, wss = new WebSocketServer({ port: 8080, perMessageDeflate:false });
var uuid = require('node-uuid');

//These will be database items in the future
var games = {}
var clients = {}

wss.on('connection', function(ws) {
  ws.on('error', function (err) {
    //handle or ignore the error
    console.log(err)
  });
  ws.clientID = uuid.v4()
  clients[ws.clientID] = ws
  ws.on('message', function incoming(message) {


    //Here we need to decide how to process this message
    console.log(message);
    //if it was a move or something then we can grabe the game with this id and send it to all of the clients
    clients[ws.clientID].send(JSON.stringify({'text':'I am pretty smart'}))

  }, function (error) {
    console.log(error)
  });
  //TODO instead of this I can just send it on interval until I get a response back
  //ALSO this may only be a problem where there is exactly 0 latency..but
  setTimeout(function() {
    ws.send(JSON.stringify({
      clientID:ws.clientID,
      joe: [
        {'text':'I am pretty smart'},
        {'text':'I am pretty smart'},
        {'text':'I am pretty smart'},
          {'text':'I am pretty smart'},
            {'text':'I am pretty smart'},
              {'text':'I am pretty smart'},
                {'text':'I am pretty smart'},
                {'text':'I am pretty smart'},
                {'text':'I am pretty smart'},
                {'text':'I am pretty smart'},
                  {'text':'I am pretty smart'},
                    {'text':'I am pretty smart'},
                      {'text':'I am pretty smart'},
                        {'text':'I am pretty smart'}
      ]
    }));
  }, 1000);
});
