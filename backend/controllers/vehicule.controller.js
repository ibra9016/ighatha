const vehiculeService = require('../services/vehicule.services');

exports.register = async (req , res , next)=>{
    try{
        const {model,company,year,status} = req.body;

        const sucess = await vehiculeService.registerVehicule(model,company,year,status);

        res.json({status:true,sucess:"vehicule registered"})
    }
    catch(err){
        throw err;
    }
}