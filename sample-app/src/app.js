const express = require('express');
const metrics = require('./metrics');
const indexRouter = require('./routes/index');
const usersRouter = require('./routes/users');

const app = express();
const port = 3000;

app.use(metrics.middleware);
app.use('/', indexRouter);
app.use('/users', usersRouter);

app.get('/metrics', async (req, res) => {
    res.set('Content-Type', metrics.register.contentType);
    res.end(await metrics.register.metrics());
});

app.listen(port, () => {
    console.log(`App running at http://localhost:${port}`);
});