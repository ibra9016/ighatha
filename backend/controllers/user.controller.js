const userService = require('../services/user.services');

exports.register = async(req , res , next)=>{
    try{
    const {username,email,password,isAdmin} = req.body;

    const success = await userService.registerUser(username,email,password,isAdmin);

    res.json({status:true,success:"User registered successfully"})
    }
    catch(err){
        throw err;
    }
}