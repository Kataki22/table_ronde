import 'package:flutter/material.dart';
import '../../models/profiles/user_activity.dart';
import 'activity_card.dart';

/// Example usage of the ActivityCard widget
/// 
/// This file demonstrates how to use the ActivityCard widget
/// with different activity types.
class ActivityCardExample extends StatelessWidget {
  const ActivityCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample activities
    final activities = [
      UserActivity(
        id: '1',
        type: 'post',
        description: 'A publié un nouveau message dans le groupe Flutter Devs',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      UserActivity(
        id: '2',
        type: 'comment',
        description: 'A commenté sur votre post "Introduction à Flutter"',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      UserActivity(
        id: '3',
        type: 'like',
        description: 'A aimé votre photo de profil',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      UserActivity(
        id: '4',
        type: 'join_group',
        description: 'A rejoint le groupe "Développeurs Mobile"',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ActivityCard Example'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ActivityCard(
            activity: activity,
            onTap: () {
              // Handle activity tap
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tapped on activity: ${activity.type}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
