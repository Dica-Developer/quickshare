const exec = require('child_process').execFile;
const storage = require('electron-json-storage');
const polo = require('polo');
const fs = require('fs');
const root = require('root');
const os = require('os');
const path = require('path');
const Busboy = require('busboy');

const fileReceiverAnnouncement = polo();
const fileReceiver = root();
const bus = riot.observable();
riot.mount('filelist', { bus: bus });
riot.mount('nearbylist', { bus: bus });

const homeFolder = process.env[(process.platform == 'win32') ? 'USERPROFILE' : 'HOME'];
const appFolder = path.join(homeFolder, '.quickshare', 'received');

fileReceiver.post('/upload', function(request, response) {
  let busboy = new Busboy({ headers: request.headers });
  busboy.on('file', function(fieldname, file, filename, encoding, mimetype) {
    console.log('Received file: ' + filename);
    let saveTo = path.join(appFolder, filename);
    file.pipe(fs.createWriteStream(saveTo));
  });
  busboy.on('finish', function() {
    response.writeHead(200, { 'Connection': 'close' });
    response.end();
    bus.trigger('watch.activities.update');
  });
  return request.pipe(busboy);
});

fileReceiver.listen(0, function(address, server) { 
  console.log('Server listening on ' + address);
  fileReceiverAnnouncement.put({
    name:'dica-developer.quickshare',
    hostname: os.hostname(),
    port: server.address().port
  });
});

