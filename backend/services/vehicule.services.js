const vehiculeModel = require('../model/vehicule.model');

class vehiculeService{
    static async registerVehicule(arrayVehicules){
        try{
            const result = vehiculeModel.insertMany(arrayVehicules);
            return await result;
        }
        catch(err){
            throw err;
        }
    }

    static async fetchVehicules(centerId){
        try{
        const result = vehiculeModel.find({center:centerId});
        return await result
        }
        catch(err){
            throw err
        }
       }

       static async deletevehicle(vehicleId){
           try{
               const result = vehiculeModel.findByIdAndDelete(vehicleId)
               return await result
           }
           catch(err){
               throw err;
           }
          }
}

module.exports = vehiculeService;