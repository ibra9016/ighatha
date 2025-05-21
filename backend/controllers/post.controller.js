const postService = require("../services/post.service");


exports.register = async(req,res,next)=>{
    try{
        if(!req.file) return res.status(400).json({ error: 'No file uploaded' });
        const { filename, path } = req.file;
        const {postedBy,description,location,isAssigned} = req.body;
        finalLocation = JSON.parse(location)
  // Make the file path relative
  const relativePath = path.replace(/^.*?uploads/, '/uploads');
    // Save the photo metadata (filename and filepath)
    const savedPhoto = await postService.registerPost(postedBy,
                                                      description,
                                                      finalLocation,                                                      
                                                      filename,
                                                      relativePath,
                                                      isAssigned);

    res.status(200).json({ message: 'Post uploaded', body: savedPhoto });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to save photo metadata' });
  
}
};

exports.getPics = async(req,res)=>{
  try{
    const allPics = await postService.getPics();
    if(allPics == null) return res.status(400).json({message:"no images found"});
    for(i = 0;i<allPics;i++){
      
    }
    res.status(200).json({ message: 'true', file: allPics });
  }
  catch(err){
    throw err
  }
};