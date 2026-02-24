import 'package:flutter/material.dart';
import 'package:tableronde_app/screens/chat_list_screen.dart';
//import 'package:tableronde_app/screens/notifications/notification_center_screen.dart';
//import 'package:tableronde_app/screens/education_screen.dart';
//import 'package:tableronde_app/screens/finance_screen.dart';
//import 'package:tableronde_app/screens/games_screen.dart';
import 'package:tableronde_app/screens/home_screen.dart';
import 'package:tableronde_app/widgets/common/bottom_nav_bar.dart';
import 'package:tableronde_app/utils/app_theme.dart';
import 'package:tableronde_app/utils/theme_extensions.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  late TabController _financeTabController;
  late TabController _educationTabController;
  late TabController _gamesTabController;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _financeTabController = TabController(length: 3, vsync: this);
    _educationTabController = TabController(length: 3, vsync: this);
    _gamesTabController = TabController(length: 3, vsync: this);

    _screens = [
      const HomeScreen(),
      const ChatListScreen(),
      //FinanceScreen(tabController: _financeTabController),
      //EducationScreen(tabController: _educationTabController),
      //GamesScreen(tabController: _gamesTabController),
    ];
  }

  @override
  void dispose() {
    _financeTabController.dispose();
    _educationTabController.dispose();
    _gamesTabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    switch (_selectedIndex) {
      case 0: // HomeScreen has its own
        return null;
      case 1: // ChatListScreen
        return null;
      /*case 2: // FinanceScreen
        return //_buildFinanceAppBar();
      case 3: // EducationScreen
        return _buildEducationAppBar();
      case 4: // GamesScreen
        return _buildGamesAppBar();*/
      default:
        return null;
    }
  }

  /*AppBar _buildFinanceAppBar() {
    return AppBar(
      backgroundColor: context.themeColorsNoWatch.bgTertiary,
      automaticallyImplyLeading: false,
      title: Text(
        'Finance & Épargne',
        style: AppTheme.headingMedium.copyWith(fontSize: 20),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.history), onPressed: () {}),
        IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: context.themeColorsNoWatch.bgTertiary,
          child: TabBar(
            controller: _financeTabController,
            indicatorColor: context.themeColorsNoWatch.colorSuccess,
            tabs: const [
              Tab(text: 'SOLDE'),
              Tab(text: 'TRANSACTIONS'),
              Tab(text: 'ÉPARGNE')
            ],
          ),
        ),
      ),
    );
  }*/

  /*AppBar _buildEducationAppBar() {
    return AppBar(
      backgroundColor: context.themeColorsNoWatch.bgTertiary,
      automaticallyImplyLeading: false,
      title: Text(
        'Espace Pédagogique',
        style: AppTheme.headingMedium.copyWith(fontSize: 20),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.calendar_today), onPressed: () {}),
        IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: context.themeColorsNoWatch.bgTertiary,
          child: TabBar(
            controller: _educationTabController,
            indicatorColor: context.themeColorsNoWatch.colorWarning,
            tabs: const [
              Tab(text: 'DEVOIRS'),
              Tab(text: 'DOCUMENTS'),
              Tab(text: 'NOTES')
            ],
          ),
        ),
      ),
    );
  }*/

  /*AppBar _buildGamesAppBar() {
    return AppBar(
      backgroundColor: context.themeColorsNoWatch.bgTertiary,
      automaticallyImplyLeading: false,
      title: Text(
        'Espace Divertissement',
        style: AppTheme.headingMedium.copyWith(fontSize: 20),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.emoji_events), onPressed: () {}),
        IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: context.themeColorsNoWatch.bgTertiary,
          child: TabBar(
            controller: _gamesTabController,
            indicatorColor: context.themeColorsNoWatch.colorBrand,
            tabs: const [
              Tab(text: 'CLASSEMENTS'),
              Tab(text: 'DÉFIS'),
              Tab(text: 'MULTIJOUEUR')
            ],
          ),
        ),
      ),
    );
  }*/

  Widget? _buildFloatingActionButton() {
    switch (_selectedIndex) {
      case 3: // FinanceScreen
        return FloatingActionButton.extended(
          heroTag: 'finance_fab',
          onPressed: _showTransactionDialog,
          backgroundColor: context.themeColorsNoWatch.colorSuccess,
          icon: const Icon(Icons.add),
          label: const Text('Transaction'),
        );
      case 4: // EducationScreen
        return FloatingActionButton.extended(
          heroTag: 'education_fab',
          onPressed: _showEducationAddDialog,
          backgroundColor: context.themeColorsNoWatch.colorWarning,
          icon: const Icon(Icons.add),
          label: const Text('Ajouter'),
        );
      case 5: // GamesScreen
        return FloatingActionButton.extended(
          heroTag: 'games_fab',
          onPressed: _showNewGameDialog,
          backgroundColor: context.themeColorsNoWatch.colorBrand,
          icon: const Icon(Icons.add),
          label: const Text('Nouveau jeu'),
        );
      default:
        return null;
    }
  }

  void _showTransactionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.themeColorsNoWatch.bgSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nouvelle transaction', style: AppTheme.headingMedium),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.send),
                          label: const Text('Envoyer'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16)))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.call_received),
                          label: const Text('Recevoir'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.successColor,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16)))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEducationAddDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ajouter', style: AppTheme.headingMedium),
            const SizedBox(height: 24),
            _buildDialogOption(
                Icons.assignment, 'Nouveau devoir', AppTheme.warningColor),
            _buildDialogOption(
                Icons.upload_file, 'Importer document', AppTheme.primaryBlue),
            _buildDialogOption(Icons.note_add, 'Créer une note', Colors.green),
          ],
        ),
      ),
    );
  }

  void _showNewGameDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nouveau jeu', style: AppTheme.headingMedium),
            const SizedBox(height: 24),
            _buildDialogOption(Icons.psychology, 'Quiz rapide', Colors.blue),
            _buildDialogOption(Icons.people, 'Partie privée', Colors.purple),
            _buildDialogOption(Icons.emoji_events, 'Tournoi', Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogOption(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: context.themeColorsNoWatch.bgSecondary,
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Text(label,
                style:
                    AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
