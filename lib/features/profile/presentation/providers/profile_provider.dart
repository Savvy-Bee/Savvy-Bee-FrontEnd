import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/service_locator.dart';

final updateProfileAvatarProvider =
    AsyncNotifierProvider.autoDispose<UpdateProfileAvatarNotifier, bool>(
      () => UpdateProfileAvatarNotifier(),
    );

class UpdateProfileAvatarNotifier extends AutoDisposeAsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return false;
  }

  Future<bool> updateAvatar(String avatarName) async {
    state = const AsyncLoading();
    try {
      final response = await ref
          .read(profileRepositoryProvider)
          .updateProfileAvatar(avatarName);

      state = AsyncData(response.success);

      return response.success;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}
