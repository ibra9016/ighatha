const requestModel = require('../model/centerRequest.model');
const userModel = require('../model/user.model');
const email = require('../emailSend');
const centerModel = require('../model/center.model')

class requestServices{
    static async createNewRequest(permitDocument,admin,center,isActivated){
        try{
            const request = new requestModel({
                permitDocument:{
                    fileName:permitDocument.filename,
                    filePath:permitDocument.relativePath
                }, admin:admin, center:center, isActivated:isActivated
            });
            const user = await userModel.findById(admin);
            const centerr = await centerModel.findById(center);
            await email.sendNotificationEmail(user.email,centerr.centerType);
            return await request.save();
        }
        catch(err){
            throw err;
        }
    }

    static async fetchRequests(){
        try{
            return await requestModel.find().populate('admin','username centerId')
                                            .populate('center','centerType');
        }
        catch(err){
            throw err;
        }
    }

    static async acceptedRequest(requestId){
        try{
        const request = await requestModel.findById(requestId);
        const user = await userModel.findByIdAndUpdate(request.admin,{isActive:true});
        const center = await centerModel.findById(request.center);
        await email.approvalNotificationEmail(user.email,center.centerType);
        return await requestModel.findByIdAndUpdate(requestId,{isActivated:true},{new:true})}
        catch(err){
            throw err;
        }
    }

    static async rejectedRequest(requestId){
        try{
        const request = await requestModel.findById(requestId);
        await userModel.findByIdAndDelete(request.admin);
        return await requestModel.findByIdAndDelete(requestId)
        }
        catch(err){
            throw err;
        }
    }
}

module.exports = requestServices;