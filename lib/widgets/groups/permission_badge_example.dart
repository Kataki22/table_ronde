import 'package:flutter/material.dart';
import '../../models/groups/group_permission.dart';
import 'permission_badge.dart';

/// Example usage of the PermissionBadge widget
/// 
/// This file demonstrates how to use the PermissionBadge widget
/// in different contexts and with different sizes.
class PermissionBadgeExample extends StatelessWidget {
  const PermissionBadgeExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Badge Examples'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example 1: Default size badges
            const Text(
              'Default Size (Medium)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                PermissionBadge(permission: GroupPermission.admin),
                SizedBox(width: 8),
                PermissionBadge(permission: GroupPermission.moderator),
                SizedBox(width: 8),
                PermissionBadge(permission: GroupPermission.member),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Example 2: Small size badges
            const Text(
              'Small Size',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                PermissionBadge(
                  permission: GroupPermission.admin,
                  size: BadgeSize.small,
                ),
                SizedBox(width: 8),
                PermissionBadge(
                  permission: GroupPermission.moderator,
                  size: BadgeSize.small,
                ),
                SizedBox(width: 8),
                PermissionBadge(
                  permission: GroupPermission.member,
                  size: BadgeSize.small,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Example 3: Large size badges
            const Text(
              'Large Size',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                PermissionBadge(
                  permission: GroupPermission.admin,
                  size: BadgeSize.large,
                ),
                SizedBox(width: 8),
                PermissionBadge(
                  permission: GroupPermission.moderator,
                  size: BadgeSize.large,
                ),
                SizedBox(width: 8),
                PermissionBadge(
                  permission: GroupPermission.member,
                  size: BadgeSize.large,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Example 4: In a list tile context
            const Text(
              'In List Tile Context',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Row(
                children: [
                  const Text('John Doe'),
                  const SizedBox(width: 8),
                  const PermissionBadge(permission: GroupPermission.admin),
                ],
              ),
              subtitle: const Text('Admin of the group'),
            ),
            
            const Divider(),
            
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Row(
                children: [
                  const Text('Jane Smith'),
                  const SizedBox(width: 8),
                  const PermissionBadge(permission: GroupPermission.moderator),
                ],
              ),
              subtitle: const Text('Moderator of the group'),
            ),
          ],
        ),
      ),
    );
  }
}
