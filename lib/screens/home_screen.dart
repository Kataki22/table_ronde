import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/theme_extensions.dart';
import '../widgets/home/home_sidebar.dart';
import '../widgets/home/home_right_sidebar.dart';
import '../widgets/home/home_feed.dart';
import '../widgets/home/home_top_bar.dart';
import '../widgets/home/announcements_feed.dart';
import '../widgets/home/members_list.dart';
import '../widgets/home/activities_feed.dart';
import '../widgets/feed/advanced_create_post_widget.dart';
import '../providers/notification_provider.dart';
import '../providers/feed_provider.dart';
import '../widgets/notifications/badge_counter.dart';
import '../screens/notifications/notification_center_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _subPageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Charger les posts depuis l'API au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedProvider>().loadPosts();
    });
  }

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: context.themeColors.bgPrimary,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle pour glisser
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: context.themeColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // En-tête
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Créer un post',
                    style: AppTheme.headingSmall.copyWith(
                      color: context.themeColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Widget de création avancé
            Expanded(
              child: SingleChildScrollView(
                child: AdvancedCreatePostWidget(
                  onPostCreated: () {
                    Navigator.pop(context);
                    // Le FeedProvider se charge automatiquement de la mise à jour
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Post créé avec succès !'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  placeholder: 'Partagez quelque chose d\'intéressant...',
                  enableScheduling: true,
                  enablePolls: true,
                  enableDrafts: true,
                ),
              ),
            ),
          ],
        ),
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
        // Feed avec données depuis l'API via FeedProvider
        return Consumer<FeedProvider>(
          builder: (context, feedProvider, _) {
            // Afficher CircularProgressIndicator pendant isLoading et liste vide
            if (feedProvider.isLoading && feedProvider.posts.isEmpty) {
              return Center(
                child: CircularProgressIndicator(
                  color: context.themeColors.colorPrimary,
                ),
              );
            }

            // Afficher message d'erreur avec bouton "Réessayer" si erreur et liste vide
            if (feedProvider.error != null && feedProvider.posts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: context.themeColors.colorDanger,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur de chargement',
                      style: AppTheme.headingSmall.copyWith(
                        color: context.themeColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feedProvider.error!,
                      style: AppTheme.bodyMedium.copyWith(
                        color: context.themeColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => feedProvider.loadPosts(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.themeColors.colorPrimary,
                        foregroundColor: context.themeColors.textInverse,
                      ),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            // Afficher snackbar si erreur et données existantes
            if (feedProvider.error != null && feedProvider.posts.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(feedProvider.error!),
                    backgroundColor: context.themeColors.colorDanger,
                    action: SnackBarAction(
                      label: 'Réessayer',
                      textColor: Colors.white,
                      onPressed: () => feedProvider.loadPosts(),
                    ),
                  ),
                );
              });
            }

            // Implémenter RefreshIndicator pour pull-to-refresh
            return RefreshIndicator(
              onRefresh: feedProvider.refreshPosts,
              color: context.themeColors.colorPrimary,
              child: Stack(
                children: [
                  HomeFeed(posts: feedProvider.posts),
                  // Afficher indicateur si isLoading et données existantes
                  if (feedProvider.isLoading && feedProvider.posts.isNotEmpty)
                    Positioned(
                      top: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: context.themeColors.bgSurface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: context.themeColors.colorPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Chargement...',
                                style: AppTheme.bodySmall.copyWith(
                                  color: context.themeColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      case 1:
        return AnnouncementsFeed(announcements: _announcements);
      case 2:
        return const MembersList();
      case 3:
        return const ActivitiesFeed();
      default:
        return Consumer<FeedProvider>(
          builder: (context, feedProvider, _) {
            if (feedProvider.isLoading && feedProvider.posts.isEmpty) {
              return Center(
                child: CircularProgressIndicator(
                  color: context.themeColors.colorPrimary,
                ),
              );
            }
            return HomeFeed(posts: feedProvider.posts);
          },
        );
    }
  }
}
