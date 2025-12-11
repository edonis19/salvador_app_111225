// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interventi_api_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$interventiApiHash() => r'58fbf843635298f07f57668af8238a6b20d85055';

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

/// See also [interventiApi].
@ProviderFor(interventiApi)
const interventiApiProvider = InterventiApiFamily();

/// See also [interventiApi].
class InterventiApiFamily extends Family<AsyncValue<List<Intervento>>> {
  /// See also [interventiApi].
  const InterventiApiFamily();

  /// See also [interventiApi].
  InterventiApiProvider call(
    String datalimite,
  ) {
    return InterventiApiProvider(
      datalimite,
    );
  }

  @override
  InterventiApiProvider getProviderOverride(
    covariant InterventiApiProvider provider,
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
  String? get name => r'interventiApiProvider';
}

/// See also [interventiApi].
class InterventiApiProvider
    extends AutoDisposeFutureProvider<List<Intervento>> {
  /// See also [interventiApi].
  InterventiApiProvider(
    String datalimite,
  ) : this._internal(
          (ref) => interventiApi(
            ref as InterventiApiRef,
            datalimite,
          ),
          from: interventiApiProvider,
          name: r'interventiApiProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$interventiApiHash,
          dependencies: InterventiApiFamily._dependencies,
          allTransitiveDependencies:
              InterventiApiFamily._allTransitiveDependencies,
          datalimite: datalimite,
        );

  InterventiApiProvider._internal(
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
    FutureOr<List<Intervento>> Function(InterventiApiRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InterventiApiProvider._internal(
        (ref) => create(ref as InterventiApiRef),
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
  AutoDisposeFutureProviderElement<List<Intervento>> createElement() {
    return _InterventiApiProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InterventiApiProvider && other.datalimite == datalimite;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, datalimite.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin InterventiApiRef on AutoDisposeFutureProviderRef<List<Intervento>> {
  /// The parameter `datalimite` of this provider.
  String get datalimite;
}

class _InterventiApiProviderElement
    extends AutoDisposeFutureProviderElement<List<Intervento>>
    with InterventiApiRef {
  _InterventiApiProviderElement(super.provider);

  @override
  String get datalimite => (origin as InterventiApiProvider).datalimite;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
