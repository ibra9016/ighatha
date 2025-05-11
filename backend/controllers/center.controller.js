const centerService = require('../services/center.services');
const userService = require('../services/user.services');

exports.register = async(req,res,next)=>{
    try{
        const {adminId,address,centerType,vehiculesCount,workersCount} = req.body;
        const center = await centerService.registerCenter(address,centerType,vehiculesCount,workersCount);
        if(center){
            const user = await userService.addCenter(adminId,center._id);
            res.status(200).json({status:true,body:center._id}); 
        }
    }   
    catch(err){
        throw err;
    }

}