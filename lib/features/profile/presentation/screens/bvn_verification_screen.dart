// lib/features/spend/presentation/screens/wallet/bvn_verification_screen.dart

import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/providers/verification_provider.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/widgets/custom_text_field.dart';

class BvnVerificationScreen extends ConsumerStatefulWidget {
  static const String path = '/bvn-verification';

  const BvnVerificationScreen({super.key});

  @override
  ConsumerState<BvnVerificationScreen> createState() =>
      _BvnVerificationScreenState();
}

class _BvnVerificationScreenState extends ConsumerState<BvnVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bvnController = TextEditingController();
  XFile? _selfieImage;
  bool _isLoading = false;
  int _currentStep = 0; // 0 = Liveness Check, 1 = BVN Input

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _bvnController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (kIsWeb) {
      // Camera KYC is not supported on web; the UI will show a fallback.
      return;
    }
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        final frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );

        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() => _isCameraInitialized = true);
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _captureSelfie() async {
    print('look');
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      print('Image: $image');
      setState(() {
        _selfieImage = image;
      });
    } catch (e) {
      debugPrint('Error capturing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _retakeSelfie() {
    print('Hmmmm');
    setState(() {
      _selfieImage = null;
    });
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selfieImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete liveness check first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // _selfieImage is already an XFile (from camera.takePicture())
      final repository = ref.read(verificationRepositoryProvider);
      final response = await repository.verifyBvn(
        bvn: _bvnController.text.trim(),
        selfieFile: _selfieImage!,
      );

      if (mounted) {
        // Check validation results
        final validation = response.data.validation;
        final isValid = response.success ||
            (validation.selfie.match &&
                validation.firstName.match &&
                validation.lastName.match);

        if (isValid) {
          if (mounted) {
            context.pop(true); // Return success to ProfileScreen
          }
        } else {
          // Show validation errors
          _showValidationErrors(validation);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog(dynamic response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 64),
            const Gap(16),
            const Text(
              'Verification Successful!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'GeneralSans',
                letterSpacing: 20 * 0.02,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your BVN has been verified successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'GeneralSans',
                letterSpacing: 14 * 0.02,
              ),
            ),
            const Gap(16),
            if (response.data.validation.selfie.confidenceRating > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified_user,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const Gap(8),
                    Text(
                      'Match Confidence: ${response.data.validation.selfie.confidenceRating}%',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'GeneralSans',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                context.pop(); // Go back to previous screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'GeneralSans',
                  letterSpacing: 16 * 0.02,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showValidationErrors(dynamic validation) {
    final errors = <String>[];

    if (!validation.firstName.match) {
      errors.add('First name does not match');
    }
    if (!validation.lastName.match) {
      errors.add('Last name does not match');
    }
    if (!validation.selfie.match) {
      errors.add(
        'Selfie verification failed (${validation.selfie.confidenceRating}% match)',
      );
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 28),
            const Gap(12),
            const Text(
              'Verification Failed',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'GeneralSans',
                letterSpacing: 18 * 0.02,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The following issues were found:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'GeneralSans',
              ),
            ),
            const Gap(12),
            ...errors.map(
              (error) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: AppColors.error)),
                    Expanded(child: Text(error)),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Confirm your identity',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w500,
            letterSpacing: 16 * 0.02,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black, size: 24),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: _currentStep == 0
          ? _buildLivenessCheckStep()
          : _buildBvnInputStep(),
    );
  }

  Widget _buildLivenessCheckStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Liveness Check',
            style: TextStyle(
              fontSize: 32,
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w500,
              color: Colors.black,
              letterSpacing: 32 * 0.02,
            ),
          ),
          const Gap(12),
          const Text(
            'We need you to provide the following to complete your identity verification.',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w400,
              color: Color(0xFF666666),
              height: 1.4,
              letterSpacing: 16 * 0.02,
            ),
          ),
          const Spacer(),

          // Camera preview or captured image
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      width: 240,
                      height: 290,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        color: Colors.black,
                      ),
                      child: _selfieImage != null
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(
                                3.14159,
                              ), // ≈ π radians → horizontal flip
                              child: Image.file(
                                File(_selfieImage!.path),
                                fit: BoxFit.cover,
                              ),
                            )
                          // ? Image.file(
                          //     File(_selfieImage!.path),
                          //     fit: BoxFit.cover,
                          //   )
                          : _isCameraInitialized && _cameraController != null
                          ? ClipRect(
                              child: OverflowBox(
                                alignment: Alignment.center,
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: SizedBox(
                                    width: 280,
                                    height:
                                        330 /
                                        _cameraController!.value.aspectRatio,
                                    child: CameraPreview(_cameraController!),
                                  ),
                                ),
                              ),
                            )
                          : const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                    ),
                    if (_selfieImage != null)
                      Positioned(
                        top: -8,
                        right: -8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF00C853),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
                const Gap(16),
                const Text(
                  'Center your face to the camera',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'GeneralSans',
                    color: Color(0xFF666666),
                    letterSpacing: 16 * 0.02,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Retake button (only show when image is captured)
          if (_selfieImage != null) ...[
            Center(
              child: TextButton.icon(
                onPressed: _retakeSelfie,
                icon: const Icon(Icons.refresh, color: Colors.black),
                label: const Text(
                  'Retake',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 16 * 0.02,
                  ),
                ),
              ),
            ),
            const Gap(16),
          ],

          // Capture/Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selfieImage != null
                  ? () async {
                      // Await disposal so native camera resources are fully
                      // released before the next screen opens its own session.
                      await _cameraController?.dispose();
                      _cameraController = null;
                      if (mounted) setState(() => _currentStep = 1);
                    }
                  : _captureSelfie,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                _selfieImage != null ? 'Continue' : 'Capture',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 16 * 0.02,
                ),
              ),
            ),
          ),
          const Gap(8),
        ],
      ),
    );
  }

  Widget _buildBvnInputStep() {
    final hasInput = _bvnController.text.length == 11;

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Submit your BVN',
              style: TextStyle(
                fontSize: 32,
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w500,
                color: Colors.black,
                letterSpacing: 32 * 0.02,
              ),
            ),
            const Gap(12),
            const Text(
              'Your BVN helps us confirm your identity with the National Identity Database.',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'GeneralSans',
                color: Color(0xFF666666),
                height: 1.4,
                letterSpacing: 16 * 0.02,
              ),
            ),
            const Gap(32),

            // BVN Input
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter your BVN',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'GeneralSans',
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 14 * 0.02,
                  ),
                ),
                const Gap(8),
                TextFormField(
                  controller: _bvnController,
                  keyboardType: TextInputType.number,
                  maxLength: 11,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'GeneralSans',
                    letterSpacing: 16 * 0.02,
                  ),
                  decoration: InputDecoration(
                    hintText: '11-digit BVN',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade300,
                      fontFamily: 'GeneralSans',
                    ),
                    counterText: '',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {}); // Rebuild to update button state
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your BVN';
                    }
                    if (value.length != 11) {
                      return 'BVN must be 11 digits';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'BVN must contain only numbers';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const Spacer(),

            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasInput && !_isLoading ? _submitVerification : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasInput
                      ? Colors.black
                      : Colors.grey.shade300,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Continue',
                        style: TextStyle(
                          color: hasInput ? Colors.white : Colors.grey.shade500,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'GeneralSans',
                          letterSpacing: 16 * 0.02,
                        ),
                      ),
              ),
            ),
            const Gap(8),
          ],
        ),
      ),
    );
  }
}
