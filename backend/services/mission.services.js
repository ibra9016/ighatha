const { model } = require('mongoose');
const missionModel = require('../model/mission.model');

class missionServices{
    static async createMission(Admin,post,crewMember,vehicle,isCompleted,startTime){
        try{
        const result = new missionModel({Admin,post,crewMember,vehicle,isCompleted,startTime})
        return await result.save();
    }
    catch(err){
        throw err;
    }
    }

    static async getMissionDetails(adminId){
        try{
            const result = missionModel.find({Admin:adminId}).populate('crewMember' , 'fullName');
            return await result
        }
        catch(err){
            throw err;
        }
    }

    static async changeStatus(missionId){
        await missionModel.updateOne({_id:missionId},{$set:{isCompleted:true}})
        const result = missionModel.findById(missionId)
        return await result;
    }
}

module.exports = missionServices;