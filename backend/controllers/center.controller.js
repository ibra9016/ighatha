const centerService = require('../services/center.services');

exports.register = async(req,res,next)=>{
    try{
        const {adress,centerType,vehiculesCount,workersCount} = req.body;
        const success = await centerService.registerCenter(adress,centerType,vehiculesCount,workersCount);
        res.json({status:true,success:"center registered successfully"});
    }   
    catch(err){
        throw err;
    }

}