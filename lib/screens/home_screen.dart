import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/theme_extensions.dart';
import '../widgets/home/home_sidebar.dart';
import '../widgets/home/home_right_sidebar.dart';
import '../widgets/home/home_feed.dart';
import '../widgets/home/home_top_bar.dart';
import '../widgets/home/announcements_feed.dart';
import '../widgets/home/create_post_dialog.dart';
import '../widgets/home/members_list.dart';
import '../widgets/home/activities_feed.dart';
import '../providers/notification_provider.dart';
import '../widgets/notifications/badge_counter.dart';
import '../screens/notifications/notification_center_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _subPageIndex = 0;

  final List<Map<String, dynamic>> _feedPosts = [
    {
      'author': 'T4zor',
      'username': '@t4zor',
      'avatar': 'T4',
      'time': '2h',
      'content': 'Il me dit f*ck you mdr.',
      'imageUrl': 'assets/images/test.png',
      'likes': 24,
      'comments': 8,
      'type': 'gaming',
    },
    {
      'author': 'Tk-Porky',
      'username': '@tkporky',
      'avatar': 'Tk',
      'time': '4h',
      'content': 'Seigneur.💔🙌 !!',
      'imageUrl': 'assets/images/test2.png',
      'likes': 45,
      'comments': 12,
      'type': 'Social',
    },
    {
      'author': 'AlistairJr',
      'username': '@alistairjr',
      'avatar': 'A',
      'time': '6h',
      'content':
          'Nouveau record ! Je suis maintenant #1 du classement Quiz Battle 🎮🏆',
      'imageUrl': null,
      'likes': 67,
      'comments': 23,
      'type': 'gaming',
    },
  ];

  final List<Map<String, dynamic>> _announcements = [
    {
      'title': 'Mise à jour importante du système',
      'badge': 'URGENT',
      'author': 'Admin Team',
      'date': '1 février 2024',
      'content':
          'Nous effectuerons une maintenance planifiée demain de 2h à 4h du matin. Tous les services seront temporairement indisponibles pendant cette période. Merci de votre compréhension.',
      'imageUrl': null,
      'likes': 45,
      'comments': 12,
    },
    {
      'title': 'Nouvelles fonctionnalités disponibles',
      'badge': 'IMPORTANT',
      'author': 'Product Team',
      'date': '31 janvier 2024',
      'content':
          'Découvrez nos nouvelles fonctionnalités : messagerie améliorée, thèmes personnalisables, et bien plus encore ! Consultez notre guide pour en savoir plus.',
      'imageUrl': null,
      'likes': 93,
      'comments': 35,
    },
    {
      'title': 'Rappel : Mise à jour de vos informations',
      'badge': 'INFO',
      'author': 'Admin Team',
      'date': '30 janvier 2024',
      'content':
          'N\'oubliez pas de mettre à jour vos informations de profil avant la fin du mois pour continuer à profiter de tous nos services.',
      'imageUrl': null,
      'likes': 28,
      'comments': 8,
    },
  ];

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => CreatePostDialog(
        onPostCreated: (content, File? image) {
          setState(() {
            _feedPosts.insert(0, {
              'author': 'Vous',
              'username': '@vous',
              'avatar': 'V',
              'time': 'À l\'instant',
              'content': content,
              'imageUrl': image,
              'likes': 0,
              'comments': 0,
              'type': 'social',
            });
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 900;

    if (isSmallScreen) {
      return Scaffold(
        backgroundColor: context.themeColors.bgPrimary,
        appBar: AppBar(
          backgroundColor: context.themeColors.bgSurface,
          title: Text('TableRonde',
              style: AppTheme.headingMedium.copyWith(
                  fontSize: 18, color: context.themeColors.textPrimary)),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
            Consumer<NotificationProvider>(
              builder: (context, notifProvider, _) {
                final unreadCount = notifProvider.unreadCount;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationCenterScreen(),
                          ),
                        );
                      },
                      tooltip: 'Notifications',
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 6,
                        top: 8,
                        child: BadgeCounter(count: unreadCount, size: 16),
                      ),
                  ],
                );
              },
            ),
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.dashboard),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: context.themeColors.bgSurface,
          child: HomeSidebar(
            isMobile: true,
            selectedIndex: _subPageIndex,
            onIndexChanged: (index) {
              setState(() => _subPageIndex = index);
              Navigator.pop(context);
            },
          ),
        ),
        endDrawer: Drawer(
          backgroundColor: context.themeColors.bgSurface,
          child: HomeRightSidebar(isMobile: true),
        ),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: _showCreatePostDialog,
          backgroundColor: context.themeColors.colorPrimary,
          child: Icon(Icons.add, color: context.themeColors.textInverse),
        ),
      );
    }

    return Row(
      children: [
        HomeSidebar(
          selectedIndex: _subPageIndex,
          onIndexChanged: (index) => setState(() => _subPageIndex = index),
        ),
        Expanded(
          child: Stack(
            children: [
              Column(
                children: [
                  HomeTopBar(onCreatePost: _showCreatePostDialog),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _buildBody()),
                        const HomeRightSidebar(),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton(
                  onPressed: _showCreatePostDialog,
                  backgroundColor: context.themeColors.colorPrimary,
                  child:
                      Icon(Icons.add, color: context.themeColors.textInverse),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_subPageIndex) {
      case 0:
        return HomeFeed(posts: _feedPosts);
      case 1:
        return AnnouncementsFeed(announcements: _announcements);
      case 2:
        return const MembersList();
      case 3:
        return const ActivitiesFeed();
      default:
        return HomeFeed(posts: _feedPosts);
    }
  }
}
