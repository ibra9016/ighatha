const { model } = require('mongoose');
const crewModel = require('../model/crew.model');

class crewService{
   static async addCrewMembers(crewArray){
    try{
        const result = crewModel.insertMany(crewArray);
        return await result
    }
    catch(err){
        throw err;
    }
   }

   static async fetchCrewMembers(centerId){
    try{
    const result = crewModel.find({center:adminId});
    return await result
    }
    catch(err){
        throw err
    }
   }
}

module.exports = crewService;