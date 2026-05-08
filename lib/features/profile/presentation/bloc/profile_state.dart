part of 'profile_cubit.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.stats,
    this.errorMessage,
  });

  final ProfileStatus status;
  final ProfileStats? stats;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileStats? stats,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, stats, errorMessage];
}
