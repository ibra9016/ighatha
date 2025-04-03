const mongoose = require('mongoose');
const db =require('../config/db');

const {Schema} = mongoose;

const vehiculeSchema = new Schema({
    plateNb :{
        type:String,
        required:true,
        unique:true
    },
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
    isOccupied:{
        type:Boolean,
        required:true
    }
});

const vehiculeModel = db.model('vehicules',vehiculeSchema);

module.exports = vehiculeModel;