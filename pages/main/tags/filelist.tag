<filelist>
    <button onclick={ openReceivedFolder } class="c-button">Open folder with received files</button>

    <table class="c-table c-table--striped">
      <thead class="c-table__head">
        <tr class="c-table__row c-table__row--heading">
          <th class="c-table__cell">
            File
          </th>
          <th class="c-table__cell">
            Time
          </th>
          <th class="c-table__cell">
            Action
          </th>
        </tr>
      </thead>
      <tbody class="c-table__body">
        <tr class="c-table__row" data-path={ path } each={ files }>
          <td class="c-table__cell">{ name }</td>
          <td class="c-table__cell">{ mtime }</td>
          <td class="c-table__cell u-super"><i title="Upload activity" class="fa fa-upload fa-2" aria-hidden="true" style="cursor: pointer;" onclick={ upload }></i><i title="Upload in progress" id={ name } style="display:none;" class="fa fa-circle-o-notch fa-spin fa-2 fa-fw"></i>
</td>
        </tr>
      </tbody>
    </table>

  <script>
    const { shell } = require('electron');
    const fs = require('fs');
    var that = this;
    const homeFolder = process.env[(process.platform == 'win32') ? 'USERPROFILE' : 'HOME'];

    this.files = [];

    openReceivedFolder() {
      shell.openItem(homeFolder + '/.quickshare/received');
    }

    function compareByTime(fileA, fileB) {
      let result = 0;
      if (fileA.mtime > fileB.mtime) {
        result = -1;
      } else if (fileA.mtime < fileB.mtime) {
        result = 1;
      }
      return result;
    }

    function collectFiles(files, root) {
      let result = new Array();
      for (index in files) {
        let status = fs.statSync(root +  files[index]);
        if (status.isDirectory()) {
          let rootDir = root + files[index] + '/';
          Array.prototype.push.apply(result, collectFiles(fs.readdirSync(rootDir), rootDir));
        } else {
          result.push({name: files[index], path: root + files[index], mtime: status.mtime });
        }
      }
      result.sort(compareByTime);
      return result;
    }

    function findFiles(directory) {
      fs.readdir(directory, function (error, files) {
        if (null !== error) {
          that.opts.bus.trigger('watch.successdialog.message', 'Error on reading local activities: ' + error);
        } else {
          let result = collectFiles(files, directory);
          that.update({
            files: result
          });
        }
      });
    }

    this.opts.bus.on('watch.activities.update', function() {
      findFiles(homeFolder + '/.quickshare/received');
    });

    fs.mkdir(homeFolder + '/.quickshare', function () {
      fs.mkdir(homeFolder + '/.quickshare/received', function () {
        that.opts.bus.trigger('watch.activities.update');
      });
    });
  </script>
</filelist>

