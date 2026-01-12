import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_unity_widget/flutter_unity_widget.dart'; // TEMPORARILY DISABLED

class GameScreen extends ConsumerStatefulWidget {
  static const String path = '/game';
  const GameScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  // UnityWidgetController? _unityWidgetController; // TEMPORARILY DISABLED
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Remove loading indicator after a timeout
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    // _unityWidgetController?.dispose(); // TEMPORARILY DISABLED
    // _unityWidgetController = null; // TEMPORARILY DISABLED
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // _unityWidgetController?.pause(); // TEMPORARILY DISABLED
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // UnityWidget( // TEMPORARILY DISABLED
              //   onUnityCreated: onUnityCreated,
              //   onUnityMessage: onUnityMessage,
              //   onUnitySceneLoaded: onUnitySceneLoaded,
              //   useAndroidViewSurface: false,
              //   fullscreen: true, // Try fullscreen
              // ),

              // Show loading only briefly
              if (_isLoading)
                Container(
                  color: Colors.black87,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Loading Unity...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // void onUnityCreated(UnityWidgetController controller) { // TEMPORARILY DISABLED
  //   print('Unity widget created');
  //   _unityWidgetController = controller;

  //   // Try to manually trigger scene load
  //   controller.resume();
  // }

  // void onUnityMessage(message) { // TEMPORARILY DISABLED
  //   print('Received message from Unity: ${message.toString()}');
  // }

  // void onUnitySceneLoaded(SceneLoaded? sceneInfo) { // TEMPORARILY DISABLED
  //   print('Unity scene loaded: ${sceneInfo?.name}');
  //   if (mounted) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }
}
