import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating_model.dart';

class RatingService {
  static final _ratingRef = FirebaseFirestore.instance.collection('ratings');

  static Future<void> addRating(RatingModel rating) async {
    // Simpan rating ke collection 'ratings'
    await _ratingRef.add(rating.toMap());
    // Tidak perlu hitung average di sini!
  }
}