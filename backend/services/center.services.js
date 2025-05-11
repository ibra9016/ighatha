const centerModel = require('../model/center.model');

class centerService{
static async registerCenter(address,centerType,vehiculesCount,workersCount){
    try{
        const createCenter = new centerModel({address,centerType,vehiculesCount,workersCount});
        return await createCenter.save();
    }
    catch(err){
        throw err;
        }
    }
}

module.exports = centerService