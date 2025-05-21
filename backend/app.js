const express = require('express');
const body_parser = require('body-parser');
const userRoute = require('./routers/user.router');
const vehiculeRoute = require('./routers/vehicule.router');
const centerRoute = require('./routers/center.router');
const postRoute = require('./routers/post.router');
const crewRoute = require('./routers/crew.router');
const missionRoute = require('./routers/mission.router');
const requestRoute = require('./routers/centerReques.router');
const cors = require('cors');

const app = express();
app.use(body_parser.json());
app.use('/',userRoute);
app.use('/',vehiculeRoute);
app.use('/',centerRoute);
app.use('/',postRoute);
app.use('/',crewRoute);
app.use('/',missionRoute);
app.use('/',requestRoute);

app.use('/uploads', express.static('uploads'));

module.exports = app;