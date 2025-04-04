const userModel = require('../model/user.model');

class userService{
    static async registerUser(email , password,isAdmin){
        try{
            const createUser = new userModel({email,password,isAdmin});
            return await createUser.save();
        }
        catch(err){
            throw err
        }
    }
}

module.exports = userService;