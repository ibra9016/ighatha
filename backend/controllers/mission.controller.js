const missionServices = require('../services/mission.services');
const postModel = require('../model/post.model');
const crewModel = require('../model/crew.model');
const vehiculeModel = require('../model/vehicule.model');

exports.createMission = async(req,res,next)=>{
    try{
    const {Admin,post,crewMember,vehicle,isCompleted,startTime} = req.body;
        const mission = await missionServices.createMission(Admin,post,crewMember,vehicle,isCompleted,startTime);
        if(mission){
            await postModel.updateOne({_id:post},{$set:{isAssigned:true}})
            await crewModel.updateOne({_id:crewMember},{$set:{isBusy:true}})
            await vehiculeModel.updateOne({_id:vehicle},{$set:{isOccupied:true}})
            res.json({status:true,body:mission});
        }
        
    }
    catch(err){
        throw err;
    }
}

exports.changeStatus = async(req,res,next)=>{
    const { missionId } = req.body;
    const mission = await missionServices.changeStatus(missionId);
    if(mission.isCompleted == true){
            await crewModel.updateOne({_id:mission.crewMember},{$set:{isBusy:false}})
            await vehiculeModel.updateOne({_id:mission.vehicle},{$set:{isOccupied:false}})
            res.json({status:true,body:"mission done"})
        }
}

exports.missionDetails = async(req,res,next)=>{
    try{
        const { adminId } = req.body; 
        const mission = await missionServices.getMissionDetails(adminId);
        res.json({status:true,body:mission});
    }
    catch(err){
        throw err;
    }
}