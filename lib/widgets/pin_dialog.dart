import 'package:flutter/material.dart';
import '../constants/color_scheme.dart';
import '../services/storage_service.dart';

class PinDialog {
  static Future<bool> verify(BuildContext context) async {
    final correctPin = StorageService.getPin();
    final pinController = TextEditingController();
    String? errorMessage;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateModal) {
          return AlertDialog(
            backgroundColor: darkGreyColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Row(
              children: const [
                Icon(Icons.lock_outline_rounded, color: primaryColor),
                SizedBox(width: 8),
                Text(
                  'Catatan Terkunci',
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
              children: [
                const Text(
                  'Masukkan PIN 4 digit untuk membuka catatan:',
                  style: TextStyle(color: lightGreyColor, fontFamily: 'Poppins', fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pinController,
                  autofocus: true,
                  obscureText: true,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 14,
                    fontFamily: 'Poppins',
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: greycolor.withOpacity(0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                  onChanged: (val) {
                    if (val.length == 4) {
                      if (val == correctPin) {
                        Navigator.pop(ctx, true);
                      } else {
                        setStateModal(() {
                          errorMessage = 'PIN salah! Coba lagi.';
                          pinController.clear();
                        });
                      }
                    }
                  },
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: dangerColor, fontSize: 12, fontFamily: 'Poppins'),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  if (pinController.text == correctPin) {
                    Navigator.pop(ctx, true);
                  } else {
                    setStateModal(() {
                      errorMessage = 'PIN salah!';
                      pinController.clear();
                    });
                  }
                },
                child: const Text('Buka', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              ),
            ],
          );
        },
      ),
    );

    return result == true;
  }

  static Future<void> changePin(BuildContext context) async {
    final pinController = TextEditingController();
    String currentPin = StorageService.getPin();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateModal) {
          return AlertDialog(
            backgroundColor: darkGreyColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Text(
              'Ubah PIN Keamanan',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PIN saat ini: $currentPin\nMasukkan PIN baru 4 digit:',
                  style: const TextStyle(color: lightGreyColor, fontFamily: 'Poppins', fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pinController,
                  autofocus: true,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 10,
                  ),
                  decoration: InputDecoration(
                    hintText: '____',
                    hintStyle: const TextStyle(color: Colors.grey, letterSpacing: 10),
                    counterText: '',
                    filled: true,
                    fillColor: greycolor.withOpacity(0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.black),
                onPressed: () async {
                  final newPin = pinController.text.trim();
                  if (newPin.length == 4) {
                    await StorageService.setPin(newPin);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PIN keamanan berhasil diperbarui!')),
                      );
                    }
                  }
                },
                child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              ),
            ],
          );
        },
      ),
    );
  }
}
