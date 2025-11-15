import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/features/home/domain/models/home_data.dart';

/// Provides the HomeData, handling loading and error states automatically.
/// It uses the HomeRepository (accessed via service_locator.dart) to fetch the data.
final homeDataProvider = FutureProvider<HomeDataResponse>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);

  // Calls the repository method to fetch the data
  return await repository.fetchHomeData();
});
