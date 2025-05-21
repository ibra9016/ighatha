const userService = require('../services/user.services');

exports.register = async(req , res , next)=>{
    try{
    const {username,email,password,isAdmin,isActive} = req.body;
        compare = await userService.checkUser(username)
        if(compare) return res.json({status:true,message:"Username is taken"})
        const user = await userService.registerUser(username,email,password,isAdmin,isActive);    
        let tokenData = {_id: user._id , username:user.username,isAdmin: user.isAdmin,center: "",isActive:user.isActive}
        const token = await userService.generateToken(tokenData,'secretkey');
        res.status(200).json({status:true,token:token});
    }
    catch(err){
        throw err;
    }
}

exports.findUser = async(req,res,next)=>{
    try{
        const {_id} = req.body;
        const user = await userService.findUser(_id);
        res.json({status:true,body: user == null? "user not found":user});
    }
    catch(err){
        throw err;
    }
}

exports.deleteUser = async(req,res,next)=>{
    try{
        const {_id} = req.body;
        const user = await userService.deleteUser(_id);
        res.json({status:true,body:user});
    }
    catch(err){
        throw err;
    }
}

exports.loginUser = async(req,res,next)=>{
    try{
        const{username,password} = req.body;
        const user = await userService.checkUser(username)
        if(!user) {
            throw new Error("user doesnt exist");
                    }

        const isMatch = await user.comparePassword(password);
        if(isMatch === false){
            throw new Error("wrong password");
        }
        let center = user.center;
        if(center == null) center = "";
        let tokenData = {_id:user._id , username:user.username,isAdmin:user.isAdmin,center:center,superAdmin:user.superAdmin,isActive:user.isActive};
        const token = await userService.generateToken(tokenData,'secretkey');
        res.status(200).json({status:true,token:token})
    }   
    catch(err){
        throw err
    }
}

exports.fetchAllUsers = async(req,res,next)=>{
    try{
        const users = await userService.fetchAllUsers();
        if(users){
            res.json({status:true,body:users})
        }
    }
    catch(err){
        throw err;
    }
}