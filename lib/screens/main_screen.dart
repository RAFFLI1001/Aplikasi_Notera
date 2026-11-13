import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/color_scheme.dart';
import '../constants/contants.dart';
import '../services/reminder_service.dart';
import '../services/storage_service.dart';
import '../widgets/pin_dialog.dart';
import 'archive_screen.dart';
import 'pages/notes_page.dart';
import 'pages/todos_page.dart';
import 'trash_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;
  int _currentPageIndex = 0;
  StreamSubscription<ReminderAlertItem>? _reminderSub;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<NotesPageState> _notesPageKey = GlobalKey<NotesPageState>();
  final GlobalKey<TodosPageState> _todosPageKey = GlobalKey<TodosPageState>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Start background timer to check for alarms/reminders on both Laptop & Mobile
    ReminderService.startListening();
    _reminderSub = ReminderService.onReminderAlert.listen(_showAlarmDialog);
  }

  @override
  void dispose() {
    _reminderSub?.cancel();
    ReminderService.stopListening();
    _pageController.dispose();
    super.dispose();
  }

  void _showAlarmDialog(ReminderAlertItem item) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: darkGreyColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.alarm_on_rounded, color: primaryColor, size: 28),
            SizedBox(width: 10),
            Text(
              'Alarm Pengingat!',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.type.toUpperCase(),
                style: const TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Waktu pengingat Anda telah tiba!',
              style: TextStyle(color: lightGreyColor, fontSize: 13, fontFamily: 'Poppins'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ReminderService.snoozeReminder(item, 5);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alarm ditunda 5 menit')),
                );
                setState(() {});
              }
            },
            child: const Text('Tunda 5 Menit', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              await ReminderService.dismissReminder(item);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) setState(() {});
            },
            child: const Text('Matikan Alarm', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }

  void _onFabPressed() {
    if (_currentPageIndex == 0) {
      _notesPageKey.currentState?.addNote();
    } else {
      _todosPageKey.currentState?.addTodo();
    }
  }

  void _showBackupDialog() {
    final jsonText = StorageService.exportBackupJson();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: darkGreyColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.save_alt_rounded, color: primaryColor),
            SizedBox(width: 8),
            Text('Cadangkan Data', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Salin teks JSON di bawah ini untuk menyimpan cadangan semua catatan dan to-do Anda:',
              style: TextStyle(color: lightGreyColor, fontSize: 13, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 12),
            Container(
              height: 140,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  jsonText,
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.black),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonText));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data cadangan disalin ke clipboard!')),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Salin Semua', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    final restoreController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: darkGreyColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.restore_page_rounded, color: primaryColor),
            SizedBox(width: 8),
            Text('Pulihkan Data', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tempel teks JSON cadangan Anda di sini untuk memulihkan catatan dan to-do:',
              style: TextStyle(color: lightGreyColor, fontSize: 13, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: restoreController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: '{\n  "app": "Notera",\n  ...\n}',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.black38,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.black),
            onPressed: () async {
              final text = restoreController.text.trim();
              if (text.isEmpty) return;
              final count = await StorageService.importBackupJson(text);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Berhasil memulihkan $count item!')),
                );
                setState(() {});
              }
            },
            child: const Text('Pulihkan', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGrid = _notesPageKey.currentState?.isGridView ?? StorageService.isGridView();

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        backgroundColor: darkGreyColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Notera',
                    style: TextStyle(
                      color: Color(0xFF1E2022),
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '"CATAT AJA BIAR GA LUPA!!"',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.sticky_note_2_outlined, color: primaryColor),
              title: const Text('Catatan Utama', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined, color: primaryColor),
              title: const Text('Arsip Catatan', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const ArchiveScreen()));
                setState(() {});
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: primaryColor),
              title: const Text('Kotak Sampah', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const TrashScreen()));
                setState(() {});
              },
            ),
            const Divider(color: Colors.white12, height: 24),
            ListTile(
              leading: const Icon(Icons.lock_outline, color: primaryColor),
              title: const Text('Atur PIN Keamanan', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
              subtitle: const Text('Ubah PIN 4-digit catatan', style: TextStyle(color: Colors.grey, fontSize: 11)),
              onTap: () {
                Navigator.pop(context);
                PinDialog.changePin(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_upload_outlined, color: primaryColor),
              title: const Text('Cadangkan Data (JSON)', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
              onTap: () {
                Navigator.pop(context);
                _showBackupDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_download_outlined, color: primaryColor),
              title: const Text('Pulihkan Data (JSON)', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
              onTap: () {
                Navigator.pop(context);
                _showRestoreDialog();
              },
            ),
            const Divider(color: Colors.white12, height: 24),
            const ListTile(
              leading: Icon(Icons.info_outline, color: primaryColor),
              title: Text('App Version', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
              subtitle: Text('1.0.0 Pro', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
            ),
            const ListTile(
              leading: Icon(Icons.person_outline, color: primaryColor),
              title: Text('Developer', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
              subtitle: Text(
                'Galih Ageng Pangestu\nMiftah Naufal\nMuhammad Raffli Arditya',
                style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.email_outlined, color: primaryColor),
              title: Text('Contact', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
              subtitle: Text('Notera@gmail.com', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              width: double.infinity,
              color: darkGreyColor,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Notera',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const Spacer(),
                  if (_currentPageIndex == 0)
                    IconButton(
                      icon: Icon(
                        isGrid ? Icons.view_agenda_outlined : Icons.grid_view_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      tooltip: isGrid ? 'Tampilan List' : 'Tampilan Grid',
                      onPressed: () {
                        _notesPageKey.currentState?.toggleViewMode();
                        setState(() {});
                      },
                    ),
                ],
              ),
            ),

            // Tab Bar Switcher
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pageController.animateToPage(
                        0,
                        duration: defaultDuration,
                        curve: Curves.easeInOut,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _currentPageIndex == 0 ? greycolor : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/notes.svg',
                              width: 20,
                              height: 20,
                              color: _currentPageIndex == 0 ? primaryColor : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Catatan',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _currentPageIndex == 0 ? primaryColor : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pageController.animateToPage(
                        1,
                        duration: defaultDuration,
                        curve: Curves.easeInOut,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _currentPageIndex == 1 ? greycolor : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/simple-icons_todoist.svg',
                              width: 20,
                              height: 20,
                              color: _currentPageIndex == 1 ? primaryColor : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'To-Do',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _currentPageIndex == 1 ? primaryColor : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Pages
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
                  TodosPage(key: _todosPageKey),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        backgroundColor: primaryColor,
        foregroundColor: const Color(0xFF1E2022),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tooltip: _currentPageIndex == 0 ? 'Tambah Catatan' : 'Tambah To-Do',
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
