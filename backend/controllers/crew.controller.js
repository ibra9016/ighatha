const crewService = require('../services/crew.services');

exports.register = async(req , res , next)=>{
    try{
    crewArray = req.body;
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
        const crew = await crewService.fetchCrewMembers(adminId)
        res.json({status:true,body:crew})

    }
    catch(err){
        throw err;
    }
}