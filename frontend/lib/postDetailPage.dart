import 'package:flutter/material.dart';

class PostDetailPage extends StatelessWidget {
  final String imageUrl; // Image URL
  final String description; // Description of the post (e.g., caption)

  const PostDetailPage({
    required this.imageUrl,
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            // Post Image Section
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 400,
              ),
            ),
            
            // Post Description Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                description,
                style: TextStyle(fontSize: 16),
              ),
            ),
            
            // Interaction Buttons (Like, Comment, Share)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.favorite_border),
                    onPressed: () {},
                  ),
                  SizedBox(width: 20),
                  IconButton(
                    icon: Icon(Icons.comment_outlined),
                    onPressed: () {},
                  ),
                  SizedBox(width: 20),
                  IconButton(
                    icon: Icon(Icons.share_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            // Divider
            Divider(),
          ],
        ),
      ),
    );
  }
}
