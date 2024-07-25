// parent_rating_screen.dart

import 'package:flutter/material.dart';

class ParentRatingScreen extends StatefulWidget {
  @override
  _ParentRatingScreenState createState() => _ParentRatingScreenState();
}

class _ParentRatingScreenState extends State<ParentRatingScreen> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate Our App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'We value your feedback! Please rate our app based on your experience.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = 1;
                    });
                  },
                  child: Icon(
                    _rating >= 1? Icons.star : Icons.star_border,
                    size: 24,
                    color: Colors.amber,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = 2;
                    });
                  },
                  child: Icon(
                    _rating >= 2? Icons.star : Icons.star_border,
                    size: 24,
                    color: Colors.amber,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = 3;
                    });
                  },
                  child: Icon(
                    _rating >= 3? Icons.star : Icons.star_border,
                    size: 24,
                    color: Colors.amber,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = 4;
                    });
                  },
                  child: Icon(
                    _rating >= 4? Icons.star : Icons.star_border,
                    size: 24,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Leave a comment (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Send rating and comment to server or analytics platform
                print('Rating: $_rating');
                print('Comment: ${_commentController.text}');
                // Show a success message or navigate to a thank you screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Thank you for your feedback!'),
                  ),
                );
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  final _commentController = TextEditingController();
}