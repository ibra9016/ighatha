const userModel = require('../model/user.model');
const bcrypt = require('bcrypt')
const jwt = require('jsonwebtoken')

class userService{
    static async registerUser(fullName,username,email ,password,isAdmin,phoneNb){
        try{
            const createUser = new userModel({fullName,username,email ,password,isAdmin,phoneNb});
            return await createUser.save();
        }
        catch(err){
            throw err
        }
    }
    static async findUser(_id){
        try{
            const user = userModel.findById(_id);
            return await user;     
        }
        catch(err){
            throw err;
        }
    }

    static async deleteUser(_id){
        try{
            // const user = userModel.deleteOne({_id:_id})
            // return await user;
            const user = await userModel.findById(_id)
            if(user == null) return "user doesnt exist";
            const result = await userModel.deleteOne({_id})
            return result
        }
        catch(err){
            throw err;
        }
    }

    static async checkUser(username){
        try{
        return await userModel.findOne({username})
    }
    catch(err){
        throw err
    }
}
    
    static async checkPass(password){
        const result = await bcrypt.compare(password,user.password);
                return result
    }

    static async generateToken(tokenData,secretkey,jwt_expire){
        return jwt.sign(tokenData,secretkey,{expiresIn:jwt_expire});
    }
}

module.exports = userService;