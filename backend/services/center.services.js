const centerModel = require('../model/center.model');

class centerService{
static async registerCenter(adress,centerType,vehiculesCount,workersCount){
    try{
        const createCenter = new centerModel({adress,centerType,vehiculesCount,workersCount});
        return await createCenter.save();
    }
    catch(err){
        throw err;
        }
    }
}

module.exports = centerService