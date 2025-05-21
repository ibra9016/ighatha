const mongoose = require('mongoose');
const db = require('../config/db');
const { use } = require('../app');
const bcrypt = require('bcrypt');

const {Schema} = mongoose;

const userSchema = new Schema({
    fullName:{
        type:String
    },
    username:{
        type:String,
        required:true,
        unique:true
    },
    email:{
        type:String,
        required:true,
        unique:true
    },
    password: {
        type:String,
        required:true,
    },
    isAdmin:{
        type:Boolean,
        required:true,
    },
    superAdmin:{
        type:Boolean
    },
    isActive:{
        type:Boolean
    },
   center:{
           type: mongoose.Schema.Types.ObjectId,
                   ref: "centers"
       }
});

userSchema.pre('save',async function() {
    if(this.password == null){

    }
    else{
    try{
        var user = this;    
        const salt = await(bcrypt.genSalt(10));
        const hasspass = await bcrypt.hash(user.password,salt);
        user.password = hasspass;
    }
    catch(err){
        throw err;
    }
}
})

userSchema.methods.comparePassword = async function(userPass){
    try{
        const isMatch = await bcrypt.compare(userPass,this.password)
        return isMatch
    }
    catch(err){
        throw err;
    }
}


const userModel = db.model('users',userSchema);

module.exports = userModel;
