import 'package:isar/isar.dart';

part 'intervento_datalimite_model.g.dart';

@collection
class InterventoSyncLog {
  InterventoSyncLog({required this.datalimite, required this.user});

  String get id => user;
  final DateTime datalimite;
  final String user;
}
