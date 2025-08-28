import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating_model.dart';

class RatingService {
  static final _ratingRef = FirebaseFirestore.instance.collection('ratings');

  static Future<void> addRating(RatingModel rating) async {
    final docId = '${rating.orderId}_${rating.userId}'; // unik per order & user
    await _ratingRef.doc(docId).set({
      ...rating.toMap(),
      'createdAt': FieldValue.serverTimestamp(), // lebih akurat
    }, SetOptions(merge: true));
  }
}