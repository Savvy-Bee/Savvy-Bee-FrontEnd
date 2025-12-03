import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/leaderboard.dart';

class LeaderboardNotifier
    extends AutoDisposeAsyncNotifier<List<LeaderboardEntry>> {
  @override
  Future<List<LeaderboardEntry>> build() async {
    final repo = ref.read(leaderboardRepositoryProvider);
    final response = await repo.getLeaderboard();

    if (response.data == null) {
      throw Exception(response.message);
    }
    return response.data!;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final repo = ref.read(leaderboardRepositoryProvider);
      final response = await repo.getLeaderboard();

      if (response.data == null) {
        throw Exception(response.message);
      }

      return response.data!;
    });
  }
}

final leaderboardProvider =
    AutoDisposeAsyncNotifierProvider<
      LeaderboardNotifier,
      List<LeaderboardEntry>
    >(LeaderboardNotifier.new);
