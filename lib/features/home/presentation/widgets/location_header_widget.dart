
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/block/registration_bloc.dart';

class LocationHeaderWidget extends StatelessWidget {
  const LocationHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RegistrationBloc>()..add(FetchLocationEvent()),
      child: BlocBuilder<RegistrationBloc, RegistrationState>(
        builder: (context, state) {
          return Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.goldPure, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: switch (state) {
                  LocationLoadingState() => Text(
                    'Detecting location...',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  LocationFetchedState(location: final loc) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.displayName,
                        style: AppTextStyles.labelMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        loc.city ?? '',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  RegistrationErrorState(message: final msg) => Text(
                    'Location unavailable',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.error),
                  ),
                  _ => Text(
                    'Tap to set location',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                },
              ),
              IconButton(
                onPressed: () =>
                    context.read<RegistrationBloc>().add(FetchLocationEvent()),
                icon: const Icon(Icons.refresh, size: 18),
                color: AppColors.textSecondary,
              ),
            ],
          );
        },
      ),
    );
  }
}