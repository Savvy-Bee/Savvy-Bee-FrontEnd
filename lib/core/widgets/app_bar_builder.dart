import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/assets/logos.dart';

import '../../features/profile/presentation/screens/profile_screen.dart';

PreferredSize buildAppBar(BuildContext context) {
  return PreferredSize(
    preferredSize: Size.fromHeight(60),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => context.pushNamed(ProfileScreen.path),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amber, width: 1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  Illustrations.dashAvatar,
                  height: 40,
                  width: 40,
                ),
              ),
            ),
            Image.asset(Logos.logo, height: 40, width: 40),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
