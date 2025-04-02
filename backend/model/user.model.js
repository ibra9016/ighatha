const mongoose = require('mongoose');
const db = require('../config/db');
const { use } = require('../app');
const bcrypt = require('bcrypt');

const {Schema} = mongoose;

const userSchema = new Schema({
    username:{
        type:String,
        required:true
    },
    email: {
        type:String,
        required:true,
        unique:true
    },
    password: {
        type:String,
        required:true
    },
    isAdmin:{
        type:Boolean,
    }
});

userSchema.pre('save',async function() {
    try{
        var user = this;    
        const salt = await(bcrypt.genSalt(10));
        const hasspass = await bcrypt.hash(user.password,salt);
        user.password = hasspass;
    }
    catch(err){
        throw err;
    }
    
})


const userModel = db.model('users',userSchema);

module.exports = userModel;
