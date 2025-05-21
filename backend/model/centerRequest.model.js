const mongoose = require('mongoose');
const db = require('../config/db');
const { use } = require('../app');

const { Schema } = mongoose;

const centerRequestSchema = new Schema({
    permitDocument:{
            fileName:{
                type:String,
                required:true
            },
            filePath:{
                type:String,
                required:true
            },
        },
    admin:{
        type: mongoose.Schema.Types.ObjectId,
                ref: "users",
                required: true
            },
    center:{
        type: mongoose.Schema.Types.ObjectId,
                ref: "centers",
                required: true
    },
    isActivated:{
        type:Boolean,
        required:true
    },
});

const requestModel = db.model('requests',centerRequestSchema);
module.exports = requestModel;