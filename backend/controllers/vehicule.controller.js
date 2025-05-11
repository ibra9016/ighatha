const vehiculeService = require('../services/vehicule.services');

exports.register = async (req , res , next)=>{
    try{
        const {arrayVehicules} = req.body;

        const sucess = await vehiculeService.registerVehicule(arrayVehicules);

        res.json({status:true,sucess: sucess})
    }
    catch(err){
        throw err;
    }
}

exports.fetchVehicules = async(req,res,next)=>{
    try{
        const { centerId } = req.body
        const crew = await vehiculeService.fetchVehicules(centerId)
        res.json({status:true,body:crew})

    }
    catch(err){
        throw err;
    }
}

exports.deletevehicle = async(req,res,next)=>{
    try{
        const{ vehicleId } = req.body;
        const result = await vehiculeService.deletevehicle(vehicleId);
        res.json({status:true,body:result});
    }
    catch(err){
        throw err;
    }
}