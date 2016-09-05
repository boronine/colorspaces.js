"use strict";

var fs = require('fs');
var highlight = require('highlight.js');
var marked = require('marked');

marked.setOptions({
  gfm: true,
  highlight(code, lang) {
    if (lang !== undefined) {
      return highlight.highlight(lang, code).value;
    }
  }
});

let readme = fs.readFileSync('README.md', {encoding: 'utf-8'});
let readme_html = marked(readme);

let full_html = `<!doctype html>
<head>
  <meta charset="utf-8">
  <title>colorspaces.js</title>
  <meta name="description" content="colorspaces.js - a tiny jQuery library for manipulating colors">
  <meta name="author" content="Alexei Boronine">
  <link href='http://fonts.googleapis.com/css?family=Droid+Sans+Mono|Droid+Serif' rel='stylesheet' type='text/css'>
  <link rel="stylesheet" href="style.css">
</head>

<body>
  <a href="https://github.com/boronine/colorspaces.js"><img style="position: absolute; top: 0; right: 0; border: 0;" src="https://s3.amazonaws.com/github/ribbons/forkme_right_darkblue_121621.png" alt="Fork me on GitHub"></a>
  <div id="content">
    ${readme_html}
    <footer>
    &copy; Copyright 2016 by Alexei Boronine
    </footer>
  </div>
  <script type="text/javascript">
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-26004435-1']);
  _gaq.push(['_trackPageview']);
  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
  </script>
</body>
</html>`;

console.log(full_html);
