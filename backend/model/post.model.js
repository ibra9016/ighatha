const mongoose = require('mongoose');
const db = require('../config/db');
const { use } = require('../app');

const { Schema } = mongoose;

const postSchema = new Schema({
    postedBy:{
        type: mongoose.Schema.Types.ObjectId,
        ref: "users",
        required: true
    },
    description:{
        type:String,
        required: true
    },
    location:{
        longtitude: {
            type:String,
            required: true
        },
        latitude:{
            type:String,
            required: true
        }
    },
    image:{
        filename:{
            type:String,
            required:true
        },
        filepath:{
            type:String,
            required:true
        }
    },
   
    isAssigned:{
        type:Boolean,
        required:true
    },
    
})

const postModel = db.model('posts',postSchema);

module.exports = postModel;