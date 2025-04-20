const postModel = require("../model/post.model");

class postService{
    static async registerPost(postedBy,description,location,filename,filepath,isAssigned){
        try{
            const createPost = new postModel({
                postedBy: postedBy,
                location:location,
                isAssigned:isAssigned,
                image:{
                    filename:filename,
                    filepath:filepath
                },
                description:description
            })
            return await createPost.save();
        }
        catch(err){
            throw err;
        }
    }

    static async getPics(){
        const pics =  postModel.find().populate('postedBy', 'username');
        return await pics;
    }
}

module.exports = postService;
