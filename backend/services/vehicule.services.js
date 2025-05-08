const vehiculeModel = require('../model/vehicule.model');

class vehiculeService{
    static async registerVehicule(arrayVehicules){
        try{
            const createVehicule = vehiculeModel.insertMany(arrayVehicules);
            return await createVehicule.save();
        }
        catch(err){
            throw err;
        }
    }
}

module.exports = vehiculeService;