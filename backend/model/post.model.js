const mongoose = require('mongoose');
const db = require('../config/db');
const { use } = require('../app');

const { Schema } = mongoose;

const postSchema = new Schema({
    // postedBy:{
    //     type: mongoose.Schema.Types.ObjectId,
    //     ref: "users",
    //     required: true
    // },
    // description:{
    //     type:String,
    //     required: true
    // },
    // location:{
    //     type:String,
    //     required:true
    // },
    image:{
        type:String,
        required:true
    },
    // isAssigned:{
    //     type:Boolean,
    //     required:true
    // },
    // center:{
    //     type:mongoose.Schema.Types.ObjectId,
    //     ref:"centers",
    // }
})

const postModel = db.model('posts',postSchema);

module.exports = postModel;