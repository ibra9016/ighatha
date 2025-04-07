const app = require('./app');
const db = require('./config/db');
const userModel = require('./model/user.model');
const vehiculeModel = require('./model/vehicule.model');
const centerModel = require('./model/center.model');
const postModel = require('./model/post.model');

const port = 3000;

app.get('/',(req,res)=>{
    res.send("helloo!!!!!!!!!!!");
});

app.listen(port,()=>{
    console.log(`Server listening on port http://localhost:${port}`);
});



