const mongoose = require('mongoose');
const db =require('../config/db');

const {Schema} = mongoose;

const vehiculeSchema = new Schema({
    model:{
        type:String,
        required:true
    },
    company:{
        type:String,
        required:true
    },
    year:{
        type:Number,
        required:true
    },
    status:{
        type:Boolean,
        required:true
    }
});

const vehiculeModel = db.model('vehicules',vehiculeSchema);

module.exports = vehiculeModel;