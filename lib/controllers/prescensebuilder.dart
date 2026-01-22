import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PresenceBuilder extends StatelessWidget {
  final String userId;
  final Widget Function(bool isOnline, int lastSeen) builder;

  const PresenceBuilder({
    super.key,
    required this.userId,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref('/status/$userId').onValue,
      builder: (context, snapshot) {
        // 1. If data is loading or null, show Offline
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return builder(false, 0);
        }

        try {
          // 2. GET RAW DATA
          final rawData = snapshot.data!.snapshot.value;

          // 3. DEBUG PRINT (Check your Run Console!)
          // print("RAW DATA for $userId: $rawData");

          // 4. SAFE PARSING
          if (rawData is Map) {
            // Safely access fields without strict casting
            final isOnline = rawData['isOnline'] == true;

            // Handle timestamp safely (could be int or double)
            int lastSeen = 0;
            final rawTime = rawData['lastSeen'];
            if (rawTime is int) {
              lastSeen = rawTime;
            } else if (rawTime is double) {
              lastSeen = rawTime.toInt();
            }

            return builder(isOnline, lastSeen);
          }

          return builder(false, 0);
        } catch (e) {
          print("Error parsing presence: $e");
          return builder(false, 0);
        }
      },
    );
  }
}
