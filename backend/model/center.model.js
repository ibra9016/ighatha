const mongoose = require('mongoose');
const db = require('../config/db');

const {Schema} = mongoose;

const centerSchema = new Schema({
    adress:{
        city:{
            type:String,
            required:true
        },
        roadName:{
            type:String,
            required:true
        },
        BuildingNb:{
            type:String,
            required:true
        }
    },
    centerType:{
        type:String,
        required:true
    },
    vehiculesCount:{
        type:Number,
        required:true
    },
    workersCount:{
        type:Number,
        required:true
    }
});

const centerModel = db.model('centers',centerSchema);

module.exports = centerModel;