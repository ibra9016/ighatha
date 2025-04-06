const express = require('express');
const body_parser = require('body-parser');
const userRoute = require('./routers/user.router');
const vehiculeRoute = require('./routers/vehicule.router');
const centerRoute = require('./routers/center.router');

const app = express();
app.use(body_parser.json());
app.use('/',userRoute);
app.use('/',vehiculeRoute);
app.use('/',centerRoute);

module.exports = app;