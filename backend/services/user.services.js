const userModel = require('../model/user.model');

class userService{
    static async registerUser(fullName,email ,password,isAdmin,phoneNb){
        try{
            const createUser = new userModel({fullName,email ,password,isAdmin,phoneNb});
            return await createUser.save();
        }
        catch(err){
            throw err
        }
    }
}

module.exports = userService;