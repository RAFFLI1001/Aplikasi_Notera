import 'package:flutter/material.dart';
import 'package:flutter_note/constants/contants.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/color_scheme.dart';
import 'pages/todos_page.dart';
import 'pages/notes_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;
  int _currentPageIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<NotesPageState> _notesPageKey = GlobalKey<NotesPageState>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Notera',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '"CATAT AJA BIAR GA LUPA!!"',
                    style: TextStyle(
                      color: Color.fromARGB(179, 0, 0, 0),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('App Version'),
              subtitle: const Text('1.0.0'),
            ),
            ListTile(
  leading: const Icon(Icons.person_outline),
  title: const Text('Developer'),
  subtitle: const Text(
  'Galih Ageng Pangestu\nMiftah Naufal\nMuhammad Raffli Arditya',
),

),

            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Contact'),
              subtitle: const Text('Notera@gmail.com'),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Menu Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              width: double.infinity,
              color: darkGreyColor,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  const Spacer(),
                  // Optional: Tambahkan sesuatu di sebelah kanan
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => _pageController.animateToPage(
                      0,
                      duration: defaultDuration,
                      curve: Curves.easeInOut,
                    ),
                    icon: SvgPicture.asset(
                      'assets/icons/notes.svg',
                      width: 26,
                      color: _currentPageIndex == 0 ? primaryColor : greycolor,
                    ),
                  ),
                  const SizedBox(width: 56),
                  IconButton(
                    onPressed: () => _pageController.animateToPage(
                      1,
                      duration: defaultDuration,
                      curve: Curves.easeInOut,
                    ),
                    icon: SvgPicture.asset(
                      'assets/icons/simple-icons_todoist.svg',
                      width: 26,
                      color: _currentPageIndex == 1 ? primaryColor : greycolor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const AlwaysScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                children: [
                  NotesPage(key: _notesPageKey),
                  const TodosPage(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _currentPageIndex == 0
          ? FloatingActionButton(
              onPressed: () => _notesPageKey.currentState?.addNote(),
              child: const Icon(Icons.add),
              backgroundColor: Colors.yellow[700],
            )
          : null,
    );
  }
}
