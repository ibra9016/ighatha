const mongoose = require('mongoose');
const db = require('../config/db');
const { use } = require('../app');

const {Schema} = mongoose;

const missionSchema = new Schema({
       Admin:{
        type: mongoose.Schema.Types.ObjectId,
        ref: "users",
        required:true
       },
       post:{
        type: mongoose.Schema.Types.ObjectId,
        ref: "posts",
        required:true
       },
       crewMember:{
        type: mongoose.Schema.Types.ObjectId,
        ref: "crew",
        required:true
       },
       vehicle:{
        type: mongoose.Schema.Types.ObjectId,
        ref: "vehicules",
        required:true
       },
       isCompleted:{
        type:Boolean,
        required:true
       },
       startTime:{
        type:String,
        required:true
       }
    });

const missionModel = db.model('missions',missionSchema);

module.exports = missionModel;
