const postModel = require("../model/post.model");

class postService{
    static async registerPost(postedBy,description,location,image,isAssigned,center){
        try{
            const createPost = new postModel({postedBy,description,location,image,isAssigned,center});
            return await createPost.save();
        }
        catch(err){
            throw err;
        }
    }
}

module.exports = postService;
