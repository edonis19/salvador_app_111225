// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'intervento_status_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

InterventoStatus _$InterventoStatusFromJson(Map<String, dynamic> json) {
  return _InterventoStatus.fromJson(json);
}

/// @nodoc
mixin _$InterventoStatus {
  @Id()
  int get idTestata => throw _privateConstructorUsedError;
  @Id()
  set idTestata(int value) => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  set status(String? value) => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InterventoStatusCopyWith<InterventoStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InterventoStatusCopyWith<$Res> {
  factory $InterventoStatusCopyWith(
          InterventoStatus value, $Res Function(InterventoStatus) then) =
      _$InterventoStatusCopyWithImpl<$Res, InterventoStatus>;
  @useResult
  $Res call({@Id() int idTestata, String? status});
}

/// @nodoc
class _$InterventoStatusCopyWithImpl<$Res, $Val extends InterventoStatus>
    implements $InterventoStatusCopyWith<$Res> {
  _$InterventoStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idTestata = null,
    Object? status = freezed,
  }) {
    return _then(_value.copyWith(
      idTestata: null == idTestata
          ? _value.idTestata
          : idTestata // ignore: cast_nullable_to_non_nullable
              as int,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InterventoStatusImplCopyWith<$Res>
    implements $InterventoStatusCopyWith<$Res> {
  factory _$$InterventoStatusImplCopyWith(_$InterventoStatusImpl value,
          $Res Function(_$InterventoStatusImpl) then) =
      __$$InterventoStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@Id() int idTestata, String? status});
}

/// @nodoc
class __$$InterventoStatusImplCopyWithImpl<$Res>
    extends _$InterventoStatusCopyWithImpl<$Res, _$InterventoStatusImpl>
    implements _$$InterventoStatusImplCopyWith<$Res> {
  __$$InterventoStatusImplCopyWithImpl(_$InterventoStatusImpl _value,
      $Res Function(_$InterventoStatusImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idTestata = null,
    Object? status = freezed,
  }) {
    return _then(_$InterventoStatusImpl(
      idTestata: null == idTestata
          ? _value.idTestata
          : idTestata // ignore: cast_nullable_to_non_nullable
              as int,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InterventoStatusImpl implements _InterventoStatus {
  _$InterventoStatusImpl({@Id() required this.idTestata, required this.status});

  factory _$InterventoStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$InterventoStatusImplFromJson(json);

  @override
  @Id()
  int idTestata;
  @override
  String? status;

  @override
  String toString() {
    return 'InterventoStatus(idTestata: $idTestata, status: $status)';
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InterventoStatusImplCopyWith<_$InterventoStatusImpl> get copyWith =>
      __$$InterventoStatusImplCopyWithImpl<_$InterventoStatusImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InterventoStatusImplToJson(
      this,
    );
  }
}

abstract class _InterventoStatus implements InterventoStatus {
  factory _InterventoStatus(
      {@Id() required int idTestata,
      required String? status}) = _$InterventoStatusImpl;

  factory _InterventoStatus.fromJson(Map<String, dynamic> json) =
      _$InterventoStatusImpl.fromJson;

  @override
  @Id()
  int get idTestata;
  @Id()
  set idTestata(int value);
  @override
  String? get status;
  set status(String? value);
  @override
  @JsonKey(ignore: true)
  _$$InterventoStatusImplCopyWith<_$InterventoStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
