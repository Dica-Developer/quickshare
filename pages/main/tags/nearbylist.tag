<nearbylist>
  <div class="o-grid o-grid--small-fit o-grid--medium-fit o-grid--large-fit o-grid--flex-wrap">
    <div name="nearbyDropZone" class="o-grid__cell" data-address={ address } each={ nearbies }>
      <div class="c-card u-high">
        <div class="c-card__item c-card__item--brand">{ hostname }</div>
        <div class="c-card__item">
          <p class="c-paragraph">{ address }</p>
        </div>
      </div> 
    </div>
  </div>

  <script>
    const polo = require('polo');
    const request = require('request');
    const fs = require('fs');
    const fileReceiver = polo();
    var that = this;

    this.nearbies = [];

    fileReceiver.on('dica-developer.quickshare/up', function(service) {
      console.info('Service found:',  service);
      that.nearbies.push(service);
      that.update({
        nearbies: that.nearbies
      });
    });

    fileReceiver.on('dica-developer.quickshare/down', function(service) {
      console.info('Service gone:', service);
    });

    function inDropZone(startElement) {
      result = false;
      if (startElement && startElement !== startElement.getRootNode()) {
        if ('nearbyDropZone' === startElement.getAttribute('name')) {
          result = true;
        } else {
          result = inDropZone(startElement.parentNode);
        }
      }
      return result;
    }

    function getDropZoneNearby(startElement) {
      result = null;
      if (startElement && startElement !== startElement.getRootNode()) {
        if ('nearbyDropZone' === startElement.getAttribute('name')) {
          result = startElement.getAttribute('data-address');
        } else {
          result = getDropZoneNearby(startElement.parentNode);
        }
      }
      return result;
    }

    document.addEventListener('dragover', function (event) {
      event.preventDefault();
      return false;
    }, false);

    document.ondrop = function(event) {
      event.preventDefault();
      if (inDropZone(event.target)) {
        for (let file of event.dataTransfer.files) {
          let receiver = getDropZoneNearby(event.target);
          console.log('File(s) you dragged here: ', file.path, receiver);
          var requestTo = request.post('http://' + receiver + '/upload', function (err, resp, body) {
            if (err) {
              console.error('Error!');
            } else {
              console.log('URL: ' + body);
            }
          });
          var form = requestTo.form();
          form.append('file', fs.createReadStream(file.path));
        }
      }
      return false;
    };

  </script>
</nearbylist>

