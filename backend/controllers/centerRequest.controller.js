const requestServices = require('../services/centerRequest.services');


exports.createRequest = async(req,res,next)=>{
    try{
        if(!req.file) return res.status(400).json({ error: 'No file uploaded' });
        const { filename, path } = req.file;
        // Make the file path relative
        const relativePath = path.replace(/^.*?uploads/, '/uploads');
        const permitDocument = {filename,relativePath};
        const {admin,center,isActivated} = req.body;
        const request = await requestServices.createNewRequest(permitDocument,admin,center,isActivated);
        if(request){
            res.json({status:true,body:request});
        }
    }
    catch(err){
        throw err;
    }
}

exports.fetchRequests = async(req,res,next)=>{
    try{
        const requests = await requestServices.fetchRequests();
        res.json({status:true,body:requests});
    }
    catch(err){
        throw err;
    }
}

exports.acceptRequest = async(req,res,next)=>{
    try{
        const { requestId } = req.body;
        const request = await requestServices.acceptedRequest(requestId);
        res.json({status:true,body:request});
    }
    catch(err){
        throw err;
    }
}

exports.rejectRequest = async(req,res,next)=>{
    try{
        const { requestId } = req.body;
        const request = await requestServices.rejectedRequest(requestId);
        res.json({status:true,body:request});
    }
    catch(err){
        throw err;
    }
}
