const express = require('express');
const app = express(); 

app.listen(8080, function () {
  console.log('아 진짜 하기 싫다다');
});

app.get('/', function (req, res) {
  res.send('Hello World!');
});