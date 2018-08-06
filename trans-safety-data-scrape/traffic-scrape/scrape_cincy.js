// scrape_ohio_DoT.js

var webPage = require('webpage');
var page = webPage.create();

var fs = require('fs');
var path = 'ohio_traffic.html'

page.open('http://www.ohgo.com/cincinnati?lt=39.30073124804121&ln=-84.77810066654459&z=10&ls=incident,construction,camera', function (status) {
  var content = page.content;
  fs.write(path,content,'w')
  phantom.exit();
});