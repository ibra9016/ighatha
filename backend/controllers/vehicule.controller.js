const vehiculeService = require('../services/vehicule.services');

exports.register = async (req , res , next)=>{
    try{
        const {plateNb,model,company,year,isOccupied} = req.body;

        const sucess = await vehiculeService.registerVehicule(plateNb,model,company,year,isOccupied);

        res.json({status:true,sucess:"vehicule registered"})
    }
    catch(err){
        throw err;
    }
}