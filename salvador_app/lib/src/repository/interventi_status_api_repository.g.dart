// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interventi_status_api_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$interventiStatusApiHash() =>
    r'b5c085094da9e65281518b0429b23f0cbfb46b85';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [interventiStatusApi].
@ProviderFor(interventiStatusApi)
const interventiStatusApiProvider = InterventiStatusApiFamily();

/// See also [interventiStatusApi].
class InterventiStatusApiFamily
    extends Family<AsyncValue<List<InterventoStatus>>> {
  /// See also [interventiStatusApi].
  const InterventiStatusApiFamily();

  /// See also [interventiStatusApi].
  InterventiStatusApiProvider call(
    String datalimite,
  ) {
    return InterventiStatusApiProvider(
      datalimite,
    );
  }

  @override
  InterventiStatusApiProvider getProviderOverride(
    covariant InterventiStatusApiProvider provider,
  ) {
    return call(
      provider.datalimite,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'interventiStatusApiProvider';
}

/// See also [interventiStatusApi].
class InterventiStatusApiProvider
    extends AutoDisposeFutureProvider<List<InterventoStatus>> {
  /// See also [interventiStatusApi].
  InterventiStatusApiProvider(
    String datalimite,
  ) : this._internal(
          (ref) => interventiStatusApi(
            ref as InterventiStatusApiRef,
            datalimite,
          ),
          from: interventiStatusApiProvider,
          name: r'interventiStatusApiProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$interventiStatusApiHash,
          dependencies: InterventiStatusApiFamily._dependencies,
          allTransitiveDependencies:
              InterventiStatusApiFamily._allTransitiveDependencies,
          datalimite: datalimite,
        );

  InterventiStatusApiProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.datalimite,
  }) : super.internal();

  final String datalimite;

  @override
  Override overrideWith(
    FutureOr<List<InterventoStatus>> Function(InterventiStatusApiRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InterventiStatusApiProvider._internal(
        (ref) => create(ref as InterventiStatusApiRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        datalimite: datalimite,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<InterventoStatus>> createElement() {
    return _InterventiStatusApiProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InterventiStatusApiProvider &&
        other.datalimite == datalimite;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, datalimite.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin InterventiStatusApiRef
    on AutoDisposeFutureProviderRef<List<InterventoStatus>> {
  /// The parameter `datalimite` of this provider.
  String get datalimite;
}

class _InterventiStatusApiProviderElement
    extends AutoDisposeFutureProviderElement<List<InterventoStatus>>
    with InterventiStatusApiRef {
  _InterventiStatusApiProviderElement(super.provider);

  @override
  String get datalimite => (origin as InterventiStatusApiProvider).datalimite;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
