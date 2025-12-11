// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interventi_db_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$interventiDbOpRepositoryHash() =>
    r'b0fb211a0e1006dcfd8d14c58c9d9f8308819fcb';

/// See also [InterventiDbOpRepository].
@ProviderFor(InterventiDbOpRepository)
final interventiDbOpRepositoryProvider = AutoDisposeAsyncNotifierProvider<
    InterventiDbOpRepository, List<Intervento>>.internal(
  InterventiDbOpRepository.new,
  name: r'interventiDbOpRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$interventiDbOpRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InterventiDbOpRepository = AutoDisposeAsyncNotifier<List<Intervento>>;
String _$interventiStateRepositoryHash() =>
    r'3cabab374b6e9d374a02629d4eedd94b4323e81b';

/// See also [InterventiStateRepository].
@ProviderFor(InterventiStateRepository)
final interventiStateRepositoryProvider =
    AsyncNotifierProvider<InterventiStateRepository, List<Intervento>>.internal(
  InterventiStateRepository.new,
  name: r'interventiStateRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$interventiStateRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InterventiStateRepository = AsyncNotifier<List<Intervento>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
