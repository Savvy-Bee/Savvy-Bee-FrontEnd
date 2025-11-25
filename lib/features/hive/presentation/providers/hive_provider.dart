import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/features/hive/data/repositories/hive_repository.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/hive.dart';

import '../../domain/models/streak.dart';

class HiveState {
  final HiveData? hiveData;
  final List<Achievement>? achievements;
  final int? currentStreak;
  final List<StreakData>? streakHistory;
  final bool isLoading;
  final String? error;

  const HiveState({
    this.hiveData,
    this.achievements,
    this.currentStreak,
    this.streakHistory,
    this.isLoading = false,
    this.error,
  });

  HiveState copyWith({
    HiveData? hiveData,
    List<Achievement>? achievements,
    int? currentStreak,
    List<StreakData>? streakHistory,
    bool? isLoading,
    String? error,
  }) {
    return HiveState(
      hiveData: hiveData ?? this.hiveData,
      achievements: achievements ?? this.achievements,
      currentStreak: currentStreak ?? this.currentStreak,
      streakHistory: streakHistory ?? this.streakHistory,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class HiveNotifier extends AutoDisposeAsyncNotifier<HiveState> {
  @override
  Future<HiveState> build() async {
    // Initialize with empty state
    return const HiveState();
  }

  HiveRepository get _repository => ref.read(hiveRepositoryProvider);

  /// Fetch complete hive details
  Future<void> fetchHiveDetails() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final response = await _repository.getHiveDetails();

      if (response.success == true) {
        final hiveData = response.data;

        final achievements = hiveData.achievement;

        return HiveState(hiveData: hiveData.hive, achievements: achievements);
      } else {
        throw Exception('Failed to fetch hive details');
      }
    });
  }

  /// Fetch streak details
  Future<void> fetchStreakDetails() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final response = await _repository.getStreakDetails();

      if (response.success == true) {
        final data = response.data;

        final currentStreak = data.currentStreak;

        final streakHistory = data.streakHistory;

        final currentState = state.valueOrNull ?? const HiveState();

        return currentState.copyWith(
          currentStreak: currentStreak,
          streakHistory: streakHistory,
        );
      } else {
        throw Exception('Failed to fetch streak details');
      }
    });
  }

  /// Top up streak
  Future<bool> topUpStreak() async {
    try {
      final response = await _repository.topUpStreak();

      if (response == true) {
        // Refresh data after successful top up
        await fetchStreakDetails();
        return true;
      }
      return false;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Top up flowers
  Future<bool> topUpFlowers(int amount) async {
    try {
      final response = await _repository.topUpResource(
        type: 'flower',
        amount: amount,
      );

      if (response == true) {
        // Refresh hive details after successful top up
        await fetchHiveDetails();
        return true;
      }
      return false;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Top up honey drops
  Future<bool> topUpHoneyDrops(int amount) async {
    try {
      final response = await _repository.topUpResource(
        type: 'honeydrop',
        amount: amount,
      );

      if (response == true) {
        // Refresh hive details after successful top up
        await fetchHiveDetails();
        return true;
      }
      return false;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Add achievement
  /// @param name - Achievement name: "Bumble", "Honey", "Mason", "Orchid", "QueenBee", "QueensGaurd", "Royal"
  Future<bool> addAchievement(String name) async {
    try {
      final response = await _repository.addAchievement(name: name);

      if (response['success'] == true) {
        // Refresh hive details after adding achievement
        await fetchHiveDetails();
        return true;
      }
      return false;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Refresh all hive data
  Future<void> refreshAll() async {
    await Future.wait([fetchHiveDetails(), fetchStreakDetails()]);
  }
}

// Provider
final hiveNotifierProvider =
    AutoDisposeAsyncNotifierProvider<HiveNotifier, HiveState>(HiveNotifier.new);
