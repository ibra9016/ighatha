const vehiculeModel = require('../model/vehicule.model');

class vehiculeService{
    static async registerVehicule(plateNb,model,company,year,isOccupied){
        try{
            const createVehicule = new vehiculeModel({plateNb,model,company,year,isOccupied});
            return await createVehicule.save();
        }
        catch(err){
            throw err;
        }
    }
}

module.exports = vehiculeService;