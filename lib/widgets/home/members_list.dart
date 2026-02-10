import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../utils/theme_extensions.dart';

class MembersList extends StatelessWidget {
  const MembersList({super.key});

  final List<Map<String, dynamic>> _members = const [
    {
      'name': 'T4zor',
      'username': '@t4zor',
      'role': 'Admin',
      'isOnline': true,
      'avatar': 'T4',
      'color': Color(0xFFE57373), // Red
    },
    {
      'name': 'Tk-Porky',
      'username': '@tkporky',
      'role': 'Modérateur',
      'isOnline': true,
      'avatar': 'Tk',
      'color': Color(0xFF81C784), // Green
    },
    {
      'name': 'AlistairJr',
      'username': '@alistairjr',
      'role': 'Membre',
      'isOnline': false,
      'avatar': 'A',
      'color': Color(0xFF64B5F6), // Blue
    },
    {
      'name': 'Not A Loli',
      'username': '@notaloli',
      'role': 'Membre',
      'isOnline': true,
      'avatar': 'N',
      'color': Color(0xFFBA68C8), // Purple
    },
    {
      'name': 'NYAJ<oo>',
      'username': '@nyaj',
      'role': 'Membre',
      'isOnline': false,
      'avatar': 'N',
      'color': Color(0xFFFFB74D), // Orange
    },
    {
      'name': 'Shadow',
      'username': '@shadow',
      'role': 'Nouveau',
      'isOnline': true,
      'avatar': 'S',
      'color': Color(0xFF90A4AE), // Grey
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _members.length,
      itemBuilder: (context, index) {
        final member = _members[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: context.themeColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.themeColors.bgSurfaceDark),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Stack(
              children: [
                CircleAvatar(
                  backgroundColor: member['color'],
                  child: Text(
                    member['avatar'],
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                if (member['isOnline'])
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: context.themeColors.colorSuccess,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: context.themeColors.bgSurface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Text(
                  member['name'],
                  style: AppTheme.bodyMedium.copyWith(
                    color: context.themeColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                if (member['role'] != 'Membre')
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getRoleColor(context, member['role'])
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      member['role'],
                      style: TextStyle(
                        color: _getRoleColor(context, member['role']),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              member['username'],
              style: AppTheme.bodySmall
                  .copyWith(color: context.themeColors.textSecondary),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.message_outlined,
                      color: context.themeColors.textSecondary),
                  onPressed: () {},
                  tooltip: 'Message',
                ),
                IconButton(
                  icon: Icon(Icons.person_outline,
                      color: context.themeColors.textSecondary),
                  onPressed: () {},
                  tooltip: 'Profil',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getRoleColor(BuildContext context, String role) {
    switch (role) {
      case 'Admin':
        return context.themeColors.colorDanger;
      case 'Modérateur':
        return context.themeColors.colorSuccess;
      case 'Nouveau':
        return context.themeColors.textSecondary;
      default:
        return context.themeColors.colorPrimary;
    }
  }
}
// TODO Implement this library.
