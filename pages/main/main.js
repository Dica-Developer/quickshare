const exec = require('child_process').execFile;
const storage = require('electron-json-storage');
const polo = require('polo');
var root = require('root');
var os = require('os');

const fileReceiverAnnouncement = polo();
const fileReceiver = root();
const bus = riot.observable();
riot.mount('filelist', { bus: bus });
riot.mount('nearbylist', { bus: bus });

fileReceiver.post('/upload', function(request, response) {
    request.on('data', function(body) {
      // TODO store parts of the file in temp file
      console.log('got part of more parts')
    });
    request.on('end', function(body) {
      // TODO finished to som clean up move to final location
      response.send(body);
    });
});

fileReceiver.listen(0, function(address, server) { 
  console.log('Server listening on ' + address);
  fileReceiverAnnouncement.put({
    name:'dica-developer.quickshare',
    hostname: os.hostname(),
    port: server.address().port
  });
});

