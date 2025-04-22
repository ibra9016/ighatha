const userService = require('../services/user.services');

exports.register = async(req , res , next)=>{
    try{
    const {username,password,isAdmin} = req.body;
        compare = await userService.checkUser(username)
        if(compare) return res.json({status:true,message:"Username is taken"})
        const user = await userService.registerUser(username,password,isAdmin);   
        let tokenData = {_id: user._id , username:user.username,isAdmin: user.isAdmin}
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

        let tokenData = {_id:user._id , username:user.username,isAdmin:user.isAdmin};
        const token = await userService.generateToken(tokenData,'secretkey');
        res.status(200).json({status:true,token:token})
    }   
    catch(err){
        throw err
    }
}