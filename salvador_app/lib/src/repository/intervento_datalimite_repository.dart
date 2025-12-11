import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:salvador_task_management/src/config/providers.dart';
import 'package:intl/intl.dart';
import 'package:salvador_task_management/src/models/intervento_datalimite_model.dart';

part 'intervento_datalimite_repository.g.dart';

@Riverpod()
class InterventoDataLimiteRepository extends _$InterventoDataLimiteRepository {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss.SSS");
  final secureStorage = const FlutterSecureStorage();

  @override
  Future<String> build() async {
    var db = await ref.read(localdbProvider.future);
    final user = await secureStorage.read(key: 'username') ?? '';

    var lastLog = await db.interventoSyncLogs.where().userMatches(user).findFirstAsync();

    var now = DateTime.now();
    var datalimitenow = DateTime(now.year, now.month, 1);
    //var datalimite = '1900-01-01 01:00:00.000';
    var datalimite = dateFormat.format(datalimitenow);
    if (lastLog != null) {
      datalimite = dateFormat.format(lastLog.datalimite);
    }

    return datalimite;
  }

  void updateDataLimite() async {
    var db = await ref.read(localdbProvider.future);
    final user = await secureStorage.read(key: 'username') ?? '';
    var interventoSyncLog = InterventoSyncLog(datalimite: DateTime.now().toUtc(), user: user);
    await db.writeAsync((isar) {
      isar.interventoSyncLogs.put(interventoSyncLog);
    });

    state = AsyncData(dateFormat.format(interventoSyncLog.datalimite));
  }
}
