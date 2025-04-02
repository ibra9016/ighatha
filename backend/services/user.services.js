const userModel = require('../model/user.model');

class userService{
    static async registerUser(username,email , password,isAdmin){
        try{
            const createUser = new userModel({username,email,password,isAdmin});
            return await createUser.save();
        }
        catch(err){
            throw err
        }
    }
}

module.exports = userService;