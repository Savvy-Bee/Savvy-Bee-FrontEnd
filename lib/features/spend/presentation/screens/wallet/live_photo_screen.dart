import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/features/action_completed_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/providers/kyc_provider.dart';

import '../../../../../core/widgets/custom_button.dart';
import 'nin_verification_screen.dart';

class LivePhotoScreen extends ConsumerStatefulWidget {
  static String path = '/live-photo';

  final Map<String, dynamic> data;

  const LivePhotoScreen({super.key, required this.data});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LivePhotoScreenState();
}

class _LivePhotoScreenState extends ConsumerState<LivePhotoScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  File? _profileImageFile;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          CustomSnackbar.show(
            context,
            'No cameras available on this device',
            type: SnackbarType.error,
            position: SnackbarPosition.bottom,
          );
        }
        return;
      }

      // Use front camera for selfie
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      await _initializeCameraController(frontCamera);
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          'Failed to initialize camera: $e',
          type: SnackbarType.error,
          position: SnackbarPosition.bottom,
        );
      }
    }
  }

  Future<void> _initializeCameraController(
    CameraDescription cameraDescription,
  ) async {
    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          'Camera initialization failed: $e',
          type: SnackbarType.error,
          position: SnackbarPosition.bottom,
        );
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _profileImageFile = File(photo.path);
        _isCapturing = false;
      });
    } catch (e) {
      setState(() {
        _isCapturing = false;
      });
      if (mounted) {
        CustomSnackbar.show(
          context,
          'Failed to capture photo: $e',
          type: SnackbarType.error,
          position: SnackbarPosition.bottom,
        );
      }
    }
  }

  void _retakePhoto() {
    setState(() {
      _profileImageFile = null;
    });
  }

  void _submitVerification() {
    final nin = widget.data[kKycNinKey] as String?;
    final bvn = widget.data[kKycBvnKey] as String?;

    if (nin == null || bvn == null || _profileImageFile == null) {
      CustomSnackbar.show(
        context,
        'Missing verification data (NIN, BVN, or Photo). Please restart the flow.',
        type: SnackbarType.error,
        position: SnackbarPosition.bottom,
      );
      return;
    }

    ref
        .read(kycNotifierProvider.notifier)
        .verifyIdentity(
          encryptedData: nin,
          profileImageFile: _profileImageFile!,
          // type: KycIdentityType.nin,
        );
  }

  Widget _buildCameraPreview(double size) {
    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: size,
        height: size,
        child: OverflowBox(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: size,
              height: size * _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(_profileImageFile!, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kycState = ref.watch(kycNotifierProvider);
    final isVerifying = kycState.isLoading;
    final screenWidth = MediaQuery.of(context).size.width;
    final squareSize = screenWidth * 0.85;

    ref.listen<AsyncValue<dynamic>>(kycNotifierProvider, (previous, next) {
      if (previous?.isLoading == true && !next.isLoading) {
        if (next.hasError) {
          final error = next.error.toString();
          CustomSnackbar.show(
            context,
            error.startsWith('Exception:')
                ? error.substring(10)
                : 'Identity verification failed. Please try again.',
            type: SnackbarType.error,
            position: SnackbarPosition.bottom,
          );
          ref.read(kycNotifierProvider.notifier).resetState();
        } else if (next.hasValue && next.value != null) {
          context.goNamed(
            ActionCompletedScreen.path,
            extra: ActionInfo(
              title: 'Wallet Created',
              message: 'Your wallet has been created successfully',
              actionText: 'Okay',
            ),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Live Photo')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Square Camera/Photo Preview
                    Center(
                      child: CustomCard(
                        padding: EdgeInsets.zero,
                        width: squareSize,
                        height: squareSize,
                        child: _profileImageFile == null
                            ? _buildCameraPreview(squareSize)
                            : _buildPhotoPreview(),
                      ),
                    ),
                    const Gap(24),

                    // Retake Button (only shown after photo is captured)
                    if (_profileImageFile != null)
                      SizedBox(
                        width: squareSize,
                        child: OutlinedButton.icon(
                          onPressed: _retakePhoto,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Retake Photo'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.black),
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Capture/Submit Button
              CustomElevatedButton(
                text: _profileImageFile == null
                    ? 'Capture Photo'
                    : 'Submit Verification',
                onPressed: isVerifying
                    ? null
                    : _profileImageFile == null
                    ? (_isCapturing || !_isCameraInitialized
                          ? null
                          : _capturePhoto)
                    : _submitVerification,
                showArrow: _profileImageFile != null,
                isLoading: isVerifying || _isCapturing,
                buttonColor: CustomButtonColor.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
