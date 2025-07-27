// ignore_for_file: unused_field, curly_braces_in_flow_structures, unnecessary_brace_in_string_interps, deprecated_member_use, unused_element, unused_local_variable, curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

import 'package:vitacal_app/screen/widgets/costum_dialog.dart';
import 'package:vitacal_app/themes/colors.dart';

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras; // Parameter wajib
  final bool isSelected; // true jika tab kamera sedang aktif

  const Camera({super.key, required this.cameras, required this.isSelected});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> with WidgetsBindingObserver {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  File? _capturedImage; // Gambar yang diambil/dipilih
  final ImagePicker _picker = ImagePicker();
  bool _isTakingPicture =
      false; // Menggunakan ini untuk loading saat ambil foto
  bool _isCameraReady = false;
  bool _hasInitializationError = false;
  FlashMode _currentFlashMode = FlashMode.off; // Default flash mati

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isSelected) {
      _initializeCamera();
    }
  }

  @override
  void didUpdateWidget(covariant Camera oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      if (_cameraController == null ||
          !_cameraController!.value.isInitialized) {
        _initializeCamera();
      }
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _disposeCamera();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      if (widget.isSelected) {
        _initializeCamera();
      }
    }
  }

  Future<void> _disposeCamera() async {
    if (_cameraController != null) {
      if (_cameraController!.value.isInitialized) {
        await _cameraController!.dispose();
      }
      _cameraController = null;
    }
    if (mounted) {
      setState(() {
        _isCameraReady = false;
        _hasInitializationError = false;
        _capturedImage = null;
      });
    }
    print('DEBUG CAMERA: Kamera dimatikan.');
  }

  Future<void> _initializeCamera() async {
    if (_cameraController != null &&
        _cameraController!.value.isInitialized &&
        _isCameraReady) {
      return;
    }
    if (_hasInitializationError && _cameraController == null) {
      // Lanjutkan inisialisasi
    } else if (_cameraController == null) {
      // Lanjutkan inisialisasi
    } else if (_cameraController != null &&
        !_cameraController!.value.isInitialized) {
      // Controller ada tapi belum terinisialisasi, coba inisialisasi ulang
    } else {
      return;
    }

    setState(() {
      _isCameraReady = false;
      _hasInitializationError = false;
    });

    if (widget.cameras.isEmpty) {
      print(
          'ERROR CAMERA: Daftar kamera kosong. Pastikan diinisialisasi di main.dart.');
      setState(() {
        _hasInitializationError = true;
      });
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return const CustomAlertDialog(
                title: "Kamera Tidak Tersedia!",
                message: "Tidak ada kamera yang terdeteksi di perangkat Anda.",
                type: DialogType.error,
                buttonText: "Oke");
          },
        );
      }
      return;
    }

    if (_cameraController != null) {
      if (_cameraController!.value.isInitialized) {
        await _cameraController!.dispose();
      }
      _cameraController = null;
    }

    _cameraController = CameraController(
      widget.cameras[0],
      // >>> Perubahan: Gunakan ResolutionPreset.max atau high untuk kualitas lebih konsisten <<<
      // Ini bisa mengurangi perbedaan antara preview dan gambar akhir
      ResolutionPreset.max, // atau .high
      enableAudio: false,
    );

    try {
      _initializeControllerFuture = _cameraController!.initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isCameraReady = true;
          _currentFlashMode = _cameraController!.value.flashMode;
        });
        print('DEBUG CAMERA: Camera controller initialized.');
      }).catchError((e) {
        print('ERROR CAMERA: Gagal menginisialisasi kamera: $e');
        setState(() {
          _hasInitializationError = true;
          _isCameraReady = false;
        });
        if (mounted) {
          String errorMessage;
          if (e is CameraException) {
            errorMessage =
                'Akses kamera ditolak. Mohon berikan izin di pengaturan.';
            if (e.code == 'CameraAccessDenied')
              errorMessage =
                  'Akses kamera ditolak. Mohon berikan izin di pengaturan.';
            else if (e.code == 'setCaptureSessionFailed')
              errorMessage =
                  'Gagal menyiapkan sesi kamera. Coba mulai ulang kamera.';
            else
              errorMessage = 'Error kamera: ${e.code}. Mohon coba lagi.';
          } else {
            errorMessage = 'Error tidak terduga: ${e.toString()}';
          }
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return CustomAlertDialog(
                  title: "Gagal Memuat Kamera",
                  message: errorMessage,
                  type: DialogType.error,
                  buttonText: "Oke");
            },
          );
        }
      });
    } catch (e) {
      print(
          'ERROR CAMERA: Terjadi error tidak terduga saat inisialisasi kamera (catch all): $e');
      setState(() {
        _hasInitializationError = true;
        _isCameraReady = false;
      });
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return CustomAlertDialog(
                title: "Gagal Memuat Kamera",
                message: 'Terjadi error tidak terduga: ${e.toString()}',
                type: DialogType.error,
                buttonText: "Oke");
          },
        );
      }
    }
  }

  Future<void> _takePicture() async {
    if (!_isCameraReady ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return const CustomAlertDialog(
                title: "Kamera Belum Siap!",
                message: "Kamera belum siap atau ada error. Mohon coba lagi.",
                type: DialogType.warning,
                buttonText: "Oke");
          },
        );
      }
      return;
    }
    if (_cameraController!.value.isTakingPicture) return;

    setState(() {
      _isTakingPicture = true; // Aktifkan indikator loading
    });

    try {
      final XFile file = await _cameraController!.takePicture();
      final Directory appDirectory = await getApplicationDocumentsDirectory();
      final String imagePath = join(
          appDirectory.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.saveTo(imagePath);

      setState(() {
        _capturedImage = File(imagePath);
        _isTakingPicture = false; // Nonaktifkan indikator loading
        print('DEBUG CAMERA: Foto berhasil diambil: ${imagePath}');
      });
    } on CameraException catch (e) {
      print('ERROR CAMERA: Gagal mengambil foto: $e');
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return CustomAlertDialog(
                title: "Gagal Ambil Foto!",
                message: 'Gagal mengambil foto: ${e.description ?? e.code}',
                type: DialogType.error,
                buttonText: "Oke");
          },
        );
      }
      setState(() {
        _isTakingPicture = false; // Nonaktifkan indikator loading
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _capturedImage = image != null ? File(image.path) : null;
      print(
          'DEBUG CAMERA: Gambar dipilih dari galeri: ${_capturedImage?.path}');
    });
    // Matikan kamera setelah memilih dari galeri
    if (_capturedImage != null) {
      _disposeCamera();
    }
  }

  Future<void> _toggleFlashMode() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    FlashMode newMode;
    switch (_currentFlashMode) {
      case FlashMode.off:
        newMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        newMode = FlashMode.always;
        break;
      case FlashMode.always:
        newMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        newMode = FlashMode.off;
        break;
    }

    try {
      await _cameraController!.setFlashMode(newMode);
      setState(() {
        _currentFlashMode = newMode;
      });
      print('DEBUG CAMERA: Mode flash diubah ke: $newMode');
    } on CameraException catch (e) {
      print('ERROR CAMERA: Gagal mengubah mode flash: $e');
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return CustomAlertDialog(
                title: "Gagal Ubah Flash!",
                message:
                    'Gagal mengubah mode flash: ${e.description ?? e.code}',
                type: DialogType.error,
                buttonText: "Oke");
          },
        );
      }
    }
  }

  IconData _getFlashIcon(FlashMode mode) {
    switch (mode) {
      case FlashMode.off:
        return Icons.flash_off_rounded;
      case FlashMode.auto:
        return Icons.flash_auto_rounded;
      case FlashMode.always:
        return Icons.flash_on_rounded;
      case FlashMode.torch:
        return Icons.flashlight_on_rounded;
    }
  }

  void _navigateToScannerScreen() {
    if (mounted) {
      print('DEBUG CAMERA: Navigasi ke layar QR/Barcode Scanner.');
      showDialog(
        context: context,
        builder: (context) => CustomAlertDialog(
          title: "Beralih Mode",
          message: "Ini akan menavigasi ke layar pemindaian QR/Barcode.",
          type: DialogType.success,
          buttonText: "Oke",
          onButtonPressed: () {
            _disposeCamera();
            Navigator.pop(context);
          },
        ),
      );
    }
  }

  Future<void> _switchCamera() async {
    // Logika ini mungkin tidak lagi digunakan di UI yang sekarang,
    // tetapi tetap dipertahankan jika ada kebutuhan.
    if (_cameraController == null || widget.cameras.length <= 1) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return const CustomAlertDialog(
                title: "Gagal Beralih Kamera!",
                message: "Tidak ada kamera lain untuk dialihkan.",
                type: DialogType.warning,
                buttonText: "Oke");
          },
        );
      }
      return;
    }

    final newCameraIndex =
        (_cameraController!.description == widget.cameras[0]) ? 1 : 0;
    await _cameraController!.dispose();
    _cameraController = CameraController(
      widget.cameras[newCameraIndex],
      ResolutionPreset.medium,
      enableAudio: false,
    );
    try {
      await _cameraController!.initialize();
      setState(() {
        _currentFlashMode = newCameraIndex == 0
            ? FlashMode.off
            : _cameraController!.value.flashMode;
      });
      print(
          'DEBUG CAMERA: Berhasil beralih ke kamera ${widget.cameras[newCameraIndex].name}');
    } on CameraException catch (e) {
      print('ERROR CAMERA: Gagal beralih kamera: $e');
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return CustomAlertDialog(
                title: "Gagal Beralih Kamera!",
                message: 'Gagal beralih kamera: ${e.description ?? e.code}',
                type: DialogType.error,
                buttonText: "Oke");
          },
        );
      }
    }
  }

  @override
  void dispose() {
    _disposeCamera();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraReady || _hasInitializationError) {
      return Scaffold(
        backgroundColor: AppColors.screen,
        appBar: AppBar(
          title: const Text('Kamera Makanan'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_hasInitializationError)
                CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 20),
              Text(
                _hasInitializationError
                    ? 'Gagal memuat kamera. Periksa izin aplikasi.'
                    : 'Memuat kamera...',
                style: const TextStyle(color: AppColors.darkGrey),
                textAlign: TextAlign.center,
              ),
              if (_hasInitializationError)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    onPressed: _initializeCamera,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGrey,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height;
    final topPadding = MediaQuery.of(context).padding.top;

    final cameraPreviewFixedW = screenWidth;
    final cameraPreviewFixedH = cameraPreviewFixedW * (5 / 4);

    const double bottomPanelHeight = 350.0;
    const double bottomPanelVerticalOffset = 0.0;

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(
          child: Text('Kamera tidak tersedia.',
              style: TextStyle(color: Colors.white)));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Latar belakang gradient hijau di bagian atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: appBarHeight + topPadding,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.greenGradient,
              ),
            ),
          ),

          // AppBar (di atas gradient, dengan tombol dan judul)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Kamera Makanan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              leading: Container(
                margin: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white),
                  onPressed: () {
                    _disposeCamera();
                    Navigator.of(context).pop();
                  },
                  tooltip: 'Kembali',
                  iconSize: 20,
                ),
              ),
              actions: [
                if (_cameraController != null &&
                    _cameraController!.value.isInitialized)
                  Container(
                    margin: const EdgeInsets.only(right: 10, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(_getFlashIcon(_currentFlashMode),
                          color: Colors.white),
                      onPressed: _toggleFlashMode,
                      tooltip: 'Ubah Mode Flash',
                      iconSize: 20,
                    ),
                  ),
              ],
            ),
          ),

          // Pratinjau Kamera
          Positioned(
            top: appBarHeight + topPadding,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: cameraPreviewFixedW,
                height: cameraPreviewFixedH,
                child: ClipRect(
                  child: OverflowBox(
                    maxWidth: double.infinity,
                    maxHeight: double.infinity,
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: cameraPreviewFixedW,
                        height: cameraPreviewFixedW *
                            _cameraController!.value.aspectRatio,
                        child: CameraPreview(_cameraController!),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Layer untuk menampilkan gambar yang diambil
          // Ini akan menutupi CameraPreview setelah gambar diambil/dipilih
          if (_capturedImage != null)
            Positioned.fill(
              child: Image.file(_capturedImage!, fit: BoxFit.cover),
            ),

          // --- Loading overlay saat _isTakingPicture ---
          // >>> Perubahan: Indikator loading lebih kecil dan tidak menutupi seluruh layar <<<
          if (_isTakingPicture)
            Center(
              // Posisikan di tengah layar
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9), // Sedikit transparan
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 4.0,
                ),
              ),
            ),
          // --- Akhir Loading overlay ---

          // Bottom Control Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: _capturedImage == null
                ? Container(
                    height: bottomPanelHeight,
                    width: screenWidth,
                    margin: EdgeInsets.only(bottom: bottomPanelVerticalOffset),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // QR/Barcode Scan Button
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.qr_code_scanner_rounded,
                                  color: AppColors.darkGrey),
                              onPressed: _navigateToScannerScreen,
                              tooltip: 'Scan QR / Barcode Gizi',
                              iconSize: 30,
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                          const Spacer(),
                          // Capture Button
                          // >>> Perubahan: Disable tombol saat _isTakingPicture <<<
                          GestureDetector(
                            onTap: _isTakingPicture
                                ? null
                                : _takePicture, // Nonaktifkan saat mengambil gambar
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isTakingPicture
                                    ? AppColors.mediumGrey
                                    : AppColors
                                        .primary, // Warna abu-abu saat disabled
                                border: Border.all(
                                    color: _isTakingPicture
                                        ? AppColors.darkGrey
                                        : AppColors.primary.withOpacity(0.5),
                                    width: 4),
                              ),
                              child: Center(
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Gallery Button
                          // >>> Perubahan: Disable tombol saat _isTakingPicture <<<
                          Container(
                            decoration: BoxDecoration(
                              color: _isTakingPicture
                                  ? AppColors.mediumGrey
                                  : AppColors
                                      .lightGrey, // Warna abu-abu saat disabled
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.image_rounded,
                                  color: AppColors.darkGrey),
                              onPressed: _isTakingPicture
                                  ? null
                                  : _pickImageFromGallery, // Nonaktifkan saat mengambil gambar
                              tooltip: 'Pilih dari Galeri',
                              iconSize: 30,
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : // If image is captured, show Retake/Process buttons
                Container(
                    height: bottomPanelHeight,
                    width: screenWidth,
                    margin: EdgeInsets.only(bottom: bottomPanelVerticalOffset),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.darkGrey,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _capturedImage = null;
                                    _initializeCamera();
                                  });
                                  print('DEBUG CAMERA: Mengambil ulang foto.');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 18),
                                ),
                                child: const Text(
                                  "Ulangi",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.greenGradient,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  print(
                                      'DEBUG CAMERA: Memproses gambar: ${_capturedImage?.path}');
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (dialogContext) {
                                      return CustomAlertDialog(
                                        title: "Gambar Siap Diproses!",
                                        message:
                                            "Foto Anda siap untuk dianalisis. Tekan OK untuk melanjutkan.",
                                        type: DialogType.success,
                                        buttonText: "Oke",
                                        onButtonPressed: () {
                                          print(
                                              'DEBUG CAMERA: Gambar diproses.');
                                        },
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 18),
                                ),
                                child: const Text(
                                  "Proses",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
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
  }
}
