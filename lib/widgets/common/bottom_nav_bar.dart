import 'package:flutter/material.dart';
import 'package:tableronde_app/utils/theme_extensions.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: context.themeColors.bgSurface,
      selectedItemColor: context.themeColors.colorPrimary,
      unselectedItemColor: context.themeColors.textSecondary,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Chat'),
        BottomNavigationBarItem(
            icon: Icon(Icons.attach_money), label: 'Finance'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Éduc'),
        BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports), label: 'Jeux'),
      ],
    );
  }
}
