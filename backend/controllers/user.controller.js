const userService = require('../services/user.services');

exports.register = async(req , res , next)=>{
    try{
    const {fullName,email ,password,isAdmin,phoneNb} = req.body;

    const success = await userService.registerUser(fullName,email ,password,isAdmin,phoneNb);

    res.json({status:true,success:"User registered successfully"});
    }
    catch(err){
        throw err;
    }
}