import 'package:flutter/material.dart' 
show AppBar, BuildContext, CircleAvatar, Colors, Column, CrossAxisAlignment, Divider, EdgeInsets, ElevatedButton, Expanded, FontWeight, Icon, IconButton, Icons, Image, InputDecoration, ListTile, ListView, OutlineInputBorder, Padding, Row, Scaffold, SizedBox, State, StatefulWidget, Text, TextEditingController, TextField, TextStyle, Widget, Wrap;

class RatingAndReviewPage extends StatefulWidget {
  @override
  _RatingAndReviewPageState createState() => _RatingAndReviewPageState();
}

class _RatingAndReviewPageState extends State<RatingAndReviewPage> {
  double _userRating = 0.0;
  TextEditingController _reviewController = TextEditingController();
  List<String> _userPhotos = [];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview() {
    String reviewText = _reviewController.text;
    // You can handle the submission logic here
    print("User rating: $_userRating");
    print("Review: $reviewText");
    print("Photos: $_userPhotos");

    // Clear the fields after submission
    setState(() {
      _userRating = 0.0;
      _reviewController.clear();
      _userPhotos.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rating & Reviews'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Average Rating
            Row(
              children: [
                Text(
                  '4.3',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(Icons.star, color: Colors.amber, size: 32),
                Text(' (72 ratings)', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 16),

            // Display Reviews List
            Expanded(
              child: ListView(
                children: [
                  _buildReviewItem("Helene Moore", 5, "The dress is great quality!"),
                  _buildReviewItem("Kate Silvan", 4, "I ordered a dress..."),
                  // More reviews can be added here
                ],
              ),
            ),

            Divider(height: 32),

            // User Rating Input
            Text(
              "What is your rating?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildRatingStars(),

            SizedBox(height: 16),

            // User Review Input
            Text(
              "Please share your opinion about the product",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Your review',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 16),

            // Add Photo Section
            _buildAddPhotoSection(),

            SizedBox(height: 16),

            // Submit Button
            ElevatedButton(
              onPressed: _submitReview,
              child: Text('Send Review'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String username, int rating, String review) {
    return ListTile(
      leading: CircleAvatar(child: Text(username[0])),
      title: Row(
        children: [
          Text(username, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          _buildRatingDisplay(rating),
        ],
      ),
      subtitle: Text(review),
    );
  }

  Widget _buildRatingDisplay(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  Widget _buildRatingStars() {
    return Row(
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _userRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 32,
          ),
          onPressed: () {
            setState(() {
              _userRating = index + 1.0;
            });
          },
        );
      }),
    );
  }

  Widget _buildAddPhotoSection() {
    return Row(
      children: [
        Expanded(
          child: Wrap(
            children: _userPhotos.map((photo) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(photo, width: 100, height: 100),
              );
            }).toList(),
          ),
        ),
        IconButton(
          icon: Icon(Icons.add_a_photo),
          onPressed: () {
            // Logic to add a photo, for now using a placeholder image
            setState(() {
              _userPhotos.add('https://via.placeholder.com/100');
            });
          },
        ),
      ],
    );
  }
}
