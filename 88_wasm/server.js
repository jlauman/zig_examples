import Path from 'path';
import Express from 'express';
import Morgan from 'morgan';
const app = Express();
const port = 8080;

app.use(Morgan('tiny'));

// app.get('/index', (req, res) => res.sendFile(__dirname + '/index.html'));
// app.use('/src/', Express.static(Path.resolve('./src')));
app.use(Express.static(Path.resolve('.')));

app.get('/hello', (req, res) => {
  res.send('Hello World!')
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Listening at http://0.0.0.0:${port}`);
});
