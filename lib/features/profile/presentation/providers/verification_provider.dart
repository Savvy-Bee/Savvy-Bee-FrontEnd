// lib/features/spend/presentation/providers/verification_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/features/profile/data/models/verification_models.dart';
import 'package:savvy_bee_mobile/features/profile/data/repositories/verification_repository.dart';
import 'dart:io';
import 'package:dio/dio.dart';

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VerificationRepository(apiClient: apiClient);
});

final verifyNinProvider =
    FutureProvider.family<
      VerificationResponse,
      ({String nin, File selfieFile})
    >((
      ref,
      params,
    ) async {
      final repository = ref.watch(verificationRepositoryProvider);
      return await repository.verifyNin(
        nin: params.nin,
        selfieFile: params.selfieFile,
      );
    });

final verifyBvnProvider =
    FutureProvider.family<
      VerificationResponse,
      ({String bvn, File selfieFile})
    >((ref, params) async {
      final repository = ref.watch(verificationRepositoryProvider);

      return await repository.verifyBvn(
        bvn: params.bvn,
        selfieFile: params.selfieFile,
      );
    });
