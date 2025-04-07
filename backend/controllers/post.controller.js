const postService = require("../services/post.service");


exports.register = async(req,res,next)=>{
    try{
        const {postedBy,description,location,image,isAssigned,center} = req.body;
        
        const sucess = await postService.registerPost(postedBy,description,location,image,isAssigned,center);

        res.json({status:true,success:"post registered successfully"})
    }
    catch(err){
        throw err;
    }
};