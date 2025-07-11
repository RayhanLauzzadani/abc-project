import 'package:flutter/material.dart';

class CartTabInProgress extends StatelessWidget {
  const CartTabInProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Sedang dalam pengembangan",
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
