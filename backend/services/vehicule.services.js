const vehiculeModel = require('../model/vehicule.model');

class vehiculeService{
    static async registerVehicule(model,company,year,status){
        try{
            const createVehicule = new vehiculeModel({model,company,year,status});
            return await createVehicule.save();
        }
        catch(err){
            throw err;
        }
    }
}

module.exports = vehiculeService;