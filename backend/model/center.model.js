const mongoose = require('mongoose');
const db = require('../config/db');

const {Schema} = mongoose;

const centerSchema = new Schema({
    address:{
        longtitude: {
            type:String,
            required: true
        },
        latitude:{
            type:String,
            required: true
        }
    },
    centerType:{
        type:String,
        required:true
    },
    vehiculesCount:{
        type:Number,
    },
    workersCount:{
        type:Number,
    }
});

const centerModel = db.model('centers',centerSchema);

module.exports = centerModel;