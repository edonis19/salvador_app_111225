// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';

part 'intervento_status_model.freezed.dart';
part 'intervento_status_model.g.dart';

@unfreezed
@Collection()
class InterventoStatus with _$InterventoStatus {
  factory InterventoStatus(
      {
      @Id() required int idTestata,
      required String? status,
      }) = _InterventoStatus;

  factory InterventoStatus.fromJson(Map<String, dynamic> json) =>
      _$InterventoStatusFromJson(json);
  factory InterventoStatus.empty() {
    return InterventoStatus(
      idTestata: 0,
      status: null,
    );
  }
}