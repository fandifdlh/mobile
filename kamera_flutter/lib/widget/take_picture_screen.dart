// Layar yang memungkinkan pengguna untuk mengambil gambar menggunakan kamera yang diberikan.
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:kamera_flutter/widget/filter_carousel.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // Untuk menampilkan output kamera saat ini,
    // buatlah CameraController.
    _controller = CameraController(
      // Ambil kamera tertentu dari daftar kamera yang tersedia.
      widget.camera,
      // Tentukan resolusi yang akan digunakan.
      ResolutionPreset.medium,
    );

    // Selanjutnya, inisialisasi controller. Ini mengembalikan sebuah Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Hapus controller saat widget dibuang.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ambil Gambar')),
      // Anda harus menunggu hingga controller diinisialisasi sebelum menampilkan
      // preview kamera. Gunakan FutureBuilder untuk menampilkan spinner loading
      // hingga controller selesai diinisialisasi.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Jika Future selesai, tampilkan preview.
            return CameraPreview(_controller);
          } else {
            // Jika belum selesai, tampilkan indikator loading.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Sediakan callback onPressed.
        onPressed: () async {
          // Ambil gambar dalam blok try / catch. Jika ada kesalahan,
          // tangani error-nya.
          try {
            // Pastikan kamera sudah diinisialisasi.
            await _initializeControllerFuture;

            // Cobalah untuk mengambil gambar dan dapatkan file `image`
            // di mana gambar tersebut disimpan.
            final image = await _controller.takePicture();

            if (!context.mounted) return;

            // Jika gambar berhasil diambil, tampilkan di layar baru.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => PhotoFilterCarousel(
                      // Kirimkan path gambar yang dihasilkan
                      // ke widget DisplayPictureScreen.
                      imagePath: image.path,
                    ),
              ),
            );
          } catch (e) {
            // Jika terjadi error, log error ke konsol.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// Widget yang menampilkan gambar yang diambil oleh pengguna.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tampilkan Gambar')),
      // Gambar disimpan sebagai file di perangkat. Gunakan konstruktor `Image.file`
      // dengan path yang diberikan untuk menampilkan gambar tersebut.
      body: Image.file(File(imagePath)),
    );
  }
}
