const vehiculeService = require('../services/vehicule.services');

exports.register = async (req , res , next)=>{
    try{
        const arrayVehicules = req.body;

        const sucess = await vehiculeService.registerVehicule(arrayVehicules);

        res.json({status:true,sucess:"vehicule registered"})
    }
    catch(err){
        throw err;
    }
}