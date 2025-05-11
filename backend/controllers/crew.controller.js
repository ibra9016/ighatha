const crewService = require('../services/crew.services');

exports.register = async(req , res , next)=>{
    try{
    const {crewArray} = req.body;
    const crew = await crewService.addCrewMembers(crewArray)
    res.json({status:true,message:"crew inserted successfully"})
    }
    catch(err){
        throw err;
    }
}

exports.fetchCrew = async(req,res,next)=>{
    try{
        const { centerId } = req.body
        const crew = await crewService.fetchCrewMembers(centerId)
        res.json({status:true,body:crew})

    }
    catch(err){
        throw err;
    }
}

exports.deleteMember = async(req,res,next)=>{
    try{
        const{ memberId } = req.body;
        const result = await crewService.deleteMember(memberId);
        res.json({status:true,body:result});
    }
    catch(err){
        throw err;
    }
}