import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/main_screen.dart';
import 'screens/chat_screen.dart';
import 'utils/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/group_chat_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/message_search_provider.dart';
import 'providers/conversation_settings_provider.dart';
import 'providers/media_gallery_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/feed_provider.dart';
import 'providers/saved_posts_provider.dart';
import 'providers/feed_search_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(
          create: (_) => ProfileProvider(),
          update: (_, authProvider, profileProvider) {
            profileProvider!.syncWithAuthUser(authProvider.currentUser);
            return profileProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, GroupChatProvider>(
          create: (_) => GroupChatProvider(),
          update: (_, authProvider, groupChatProvider) {
            groupChatProvider!.syncWithAuthUser(authProvider.currentUser);
            return groupChatProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => MessageSearchProvider()),
        ChangeNotifierProvider(create: (_) => ConversationSettingsProvider()),
        ChangeNotifierProvider(create: (_) => MediaGalleryProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProxyProvider<AuthProvider, FeedProvider>(
          create: (_) => FeedProvider(),
          update: (_, authProvider, feedProvider) {
            feedProvider!.syncWithAuthUser(authProvider.currentUser);
            return feedProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => SavedPostsProvider()),
        ChangeNotifierProvider(create: (_) => FeedSearchProvider()),
      ],
      child: const TableRondeApp(),
    ),
  );
}

class TableRondeApp extends StatelessWidget {
  const TableRondeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'TableRonde',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.generateThemeData(themeProvider.currentTheme),
          darkTheme: AppTheme.generateThemeData(themeProvider.currentTheme),
          themeMode: ThemeMode.dark,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/welcome': (context) => const WelcomeScreen(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/otp': (context) => const OTPVerificationScreen(),
            '/profile-setup': (context) => const ProfileSetupScreen(),
            '/home': (context) => const MainScreen(),
            '/chat': (context) => const ChatScreen(),
          },
        );
      },
    );
  }
}
