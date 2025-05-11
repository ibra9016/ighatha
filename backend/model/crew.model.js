const mongoose = require('mongoose');
const db = require('../config/db');
const { use } = require('../app');

const {Schema} = mongoose;

const crewSchema = new Schema({
       fullName:{
        type:String,
        required:true
       },
       phoneNb:{
        type:String,
        required:true
       },
       isBusy:{
        type:Boolean,
        required:true
       },
       center:{
        type: mongoose.Schema.Types.ObjectId,
        ref: "centers",
       }
    });

const crewModel = db.model('crew',crewSchema);

module.exports = crewModel;
