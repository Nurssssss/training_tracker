import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../workouts/domain/workouts_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._workoutsRepo) : super(const ProfileState());

  final WorkoutsRepository _workoutsRepo;

  Future<void> load() async {
    emit(state.copyWith(status: ProfileStatus.loading, clearError: true));
    try {
      final stats = await _workoutsRepo.fetchStats();
      emit(state.copyWith(status: ProfileStatus.success, stats: stats));
    } on Failure catch (f) {
      emit(state.copyWith(status: ProfileStatus.failure, errorMessage: f.message));
    }
  }
}
