# Notera - Catatan & To-Do List App (Pro Edition)

> *"CATAT AJA BIAR GA LUPA!!"*

Notera adalah aplikasi pencatatan (*note-taking*) dan manajemen tugas (*to-do list*) modern berbasis **Flutter**. Aplikasi ini didesain dengan antarmuka yang bersih, responsif, dan kaya fitur untuk mendukung produktivitas harian secara maksimal.

---

## 🌟 Fitur Lengkap

### 1. 📝 Catatan (Notes)
- **Editor Penuh:** Tulis judul dan isi catatan tanpa batas panjang (*auto-expand*).
- **Palet Warna Pastel:** Pilih warna kartu catatan dengan kontras teks otomatis yang nyaman dibaca.
- **🏷️ Kategori & Label (#Tags):** Kelola catatan berdasarkan tag (`#Kuliah`, `#Kerja`, `#Pribadi`, `#Ide`, `#Belanja`).
- **🔲 Toggle Tampilan (Grid vs List):** Berpindah antara tampilan Grid 2-kolom (*Masonry*) atau List 1-kolom memanjang dalam 1 ketukan.
- **📌 Sematkan Catatan (Pin Note):** Catatan prioritas selalu tampil di urutan paling atas.
- **🔒 Kunci Catatan dengan PIN (Secret Note):** Lindungi catatan pribadi/rahasia dengan PIN 4-digit. Isi catatan disembunyikan sampai PIN berhasil diverifikasi.
- **⏰ Pengingat Waktu (Reminder):** Pasang tanggal dan jam pengingat pada catatan.
- **📋 Salin Cepat:** Salin seluruh teks catatan ke clipboard dalam satu ketukan.
- **✍️ Penghitung Kata & Huruf:** Indikator *real-time* jumlah kata dan karakter.

### 2. ✅ To-Do List
- **Checklist Tugas:** Tandai tugas yang selesai dengan efek coret teks (*strike-through*).
- **📊 Progress Tracker:** Kartu persentase penyelesaian tugas (contoh: *"Progress Tugas: 3 dari 5 selesai (60%)"*) dengan bilah kemajuan visual.
- **Kategori & Deadline:** Berikan tag kategori dan tanggal tenggat waktu pada to-do.
- **Swipe Actions:** Geser (*swipe*) untuk mengedit atau menghapus to-do dengan cepat.

### 3. 🗄️ Arsip & 🗑️ Kotak Sampah
- **Arsip Catatan:** Sembunyikan catatan yang sudah selesai dari layar utama tanpa menghapusnya.
- **Kotak Sampah (Trash Bin):** Catatan yang dihapus masuk ke kotak sampah terlebih dahulu, bisa dipulihkan (*restore*) kapan saja atau dikosongkan secara permanen.

### 4. 💾 Cadangkan & Pulihkan Data (Backup & Restore JSON)
- **Ekspor Data:** Cadangkan seluruh catatan dan to-do ke format JSON yang dapat disimpan atau disalin.
- **Impor / Pulihkan:** Tempelkan data cadangan untuk memulihkan seluruh catatan saat berganti perangkat.

### 5. 🔍 Pencarian Real-Time & Filter Kategori
- Cari catatan atau to-do secara instan berdasarkan kata kunci atau tag kategori.
- Bilah filter kategori horizontal yang mudah digulir.
- Tombol silang (*clear*) satu ketukan untuk mereset pencarian.

### 6. 🚀 Offline-First & Performa Tinggi
- Menggunakan arsitektur **Dual-Layer Storage** (In-Memory Cache + **Hive Database**) sehingga data dijamin 100% tersimpan aman, instan, dan dapat diakses tanpa koneksi internet.

---

## 📁 Struktur Direktori

```text
lib/
├── constants/          # Konfigurasi warna, tema, dan durasi animasi
│   ├── color_scheme.dart
│   ├── constants.dart
│   ├── contants.dart
│   └── theme.dart
├── models/             # Data model untuk Catatan & To-Do
│   ├── note.dart
│   └── todo.dart
├── routes/             # Rute navigasi aplikasi
│   ├── app_routes.dart
│   └── route_names.dart
├── screens/            # Layar aplikasi
│   ├── pages/
│   │   ├── notes_page.dart
│   │   └── todos_page.dart
│   ├── archive_screen.dart # Layar arsip catatan
│   ├── input_screen.dart   # Editor catatan lengkap
│   ├── main_screen.dart    # Dashboard utama
│   ├── splash_screen.dart  # Layar pembuka video interaktif
│   └── trash_screen.dart   # Layar kotak sampah
├── services/           # Logika penyimpanan & backup
│   └── storage_service.dart # Hive Database & In-Memory Store
└── widgets/            # Komponen UI reusable
    ├── note_card.dart
    ├── pin_dialog.dart     # Dialog PIN keamanan
    └── search_input.dart
```

---

## 🚀 Cara Menjalankan Aplikasi

1. Masuk ke direktori proyek:
   ```bash
   cd "d:/CODINGAN/Aplikasi notera"
   ```
2. Jalankan aplikasi:
   ```bash
   flutter run
   ```

---

## 👥 Pengembang
- **Galih Ageng Pangestu**
- **Miftah Naufal**
- **Muhammad Raffli Arditya**

*Notera © 2026. All rights reserved.*
