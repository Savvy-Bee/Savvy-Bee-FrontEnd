import 'package:riverpod/riverpod.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:savvy_bee_mobile/features/dashboard/domain/models/dashboard_data.dart';

// Provider code - put this in your provider file
class DashboardDataNotifier
    extends AutoDisposeFamilyAsyncNotifier<DashboardData, String> {
  @override
  Future<DashboardData> build(String bankId) async {
    return await ref
        .read(dashboardRepositoryProvider)
        .fetchDashboardData(bankId)
        .then((response) => response.data!);
  }
}

final dashboardDataProvider =
    AutoDisposeAsyncNotifierProvider.family<
      DashboardDataNotifier,
      DashboardData,
      String
    >(DashboardDataNotifier.new);

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepository(ref.read(apiClientProvider)),
);
