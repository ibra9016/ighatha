const userService = require('../services/user.services');

exports.register = async(req , res , next)=>{
    try{
    const {email,password,isAdmin} = req.body;

    const success = await userService.registerUser(email,password,isAdmin);

    res.json({status:true,success:"User registered successfully"})
    }
    catch(err){
        throw err;
    }
}