import 'package:flutter/material.dart';

class EmptyContactsView extends StatelessWidget {
  const EmptyContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 70,
            color: Colors.grey.shade200,
          ),
          const SizedBox(height: 16),
          const Text(
            "No users found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}