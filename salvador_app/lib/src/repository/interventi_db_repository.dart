import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:salvador_task_management/src/config/providers.dart';
import 'package:salvador_task_management/src/features/pages/interventi_aperti/interventi_datasource.dart';
import 'package:salvador_task_management/src/models/intervento_model.dart';
import 'package:salvador_task_management/src/repository/interventi_api_repository.dart';
import 'package:salvador_task_management/src/repository/interventi_status_api_repository.dart';
import 'package:salvador_task_management/src/repository/intervento_datalimite_repository.dart';

part 'interventi_db_repository.g.dart';

// use this only for underlying db operations. use the InterventiStateRepository for operations.
@Riverpod()
class InterventiDbOpRepository extends _$InterventiDbOpRepository {
  @override
  Future<List<Intervento>> build() async {
    var erpdb = await ref.read(erpdbProvider.future);
    var erpinterventi = await erpdb.interventos.where().build().findAllAsync();

    var localdb = await ref.read(localdbProvider.future);
    var localinterventi =
        await localdb.interventos.where().build().findAllAsync();

    //  var archividb = await ref.read(archividbProvider.future);
    //  var archivinterventi =
    //      await archividb.interventos.where().build().findAllAsync();

    var result = [
      ...erpinterventi.where(
          (ei) => !localinterventi.any((li) => li.idTestata == ei.idTestata)),
      ...localinterventi,
      // ...archivinterventi
    ];

    return result;
  }

  Future<List<Intervento>> getInterventiErp() async {
    final erpdb = await ref.read(erpdbProvider.future);
    final interventiErp =
        await erpdb.interventos.where().build().findAllAsync();
    return interventiErp;
  }

  Future<void> deleteInterventoById(Intervento intervento) async {
    try {
      final id = intervento.idTestata;

      var db = await ref.read(localdbProvider.future);
      final deletedLocal = await db.writeAsync((isar) {
        return isar.interventos.delete(id);
      });

      print(deletedLocal
          ? '✅ Cancellato da localdb'
          : '❌ Non trovato in localdb');

      if (intervento.numDoc != 'null') {
        var dbErp = await ref.read(erpdbProvider.future);
        final deletedErp = await dbErp.writeAsync((isar) {
          return isar.interventos.delete(id);
        });

        print(deletedErp ? '✅ Cancellato da erpdb' : '❌ Non trovato in erpdb');
      }
    } catch (e, st) {
      print('❌ Errore durante cancellazione: $e');
    }
  }

  Future<void> deleteInterventoFromErp(
      String? numDoc, Intervento intervento) async {
    try {
      var db = await ref.read(erpdbProvider.future);
      await db.writeAsync((isar) {
        isar.interventos.delete(intervento.idTestata);
      });
    } catch (e) {
      print('Error deleting Intervento from ERP: $e');
    }
  }

  Future<void> removeAllInterventi(
      List<Intervento> interventi, bool localInterventi) async {
    try {
      final idsToDelete =
          interventi.map((i) => i.idTestata).where((id) => id > 0).toList();

      var erpdb = await ref.read(erpdbProvider.future);
      await erpdb.writeAsync((isar) {
        return isar.interventos.deleteAll(idsToDelete);
      });

      if (localInterventi) {
        var localdb = await ref.read(localdbProvider.future);

        final existing = localdb.interventos.getAll(idsToDelete);
        final existingIds =
            existing.where((e) => e != null).map((e) => e!.idTestata).toList();

        await localdb.writeAsync((isar) {
          return isar.interventos.deleteAll(existingIds);
        });
      }
    } catch (e, st) {
      print('❌ Error removing interventi: $e');
      print(st);
    }
  }

  // no need to read from db. we work with the in memory data - see parameter keepAlive : true
  // Future<int?> findDocIdByNumDoc(String? numDoc) async {
  //   var db = await ref.read(localdbProvider.future);
  //   var intervento = db.interventos.where().numDocEqualTo(numDoc).findFirst();

  //   return intervento?.idTestata;
  // }

  Future<void> updateInterventiErp(List<Intervento> erpinterventi) async {
    //state = const AsyncLoading();
    var db = await ref.read(erpdbProvider.future);
    await db.writeAsync((isar) {
      isar.interventos.putAll(erpinterventi);
    });
    //state = AsyncData(erpinterventi);
  }

  Future<void> addOrUpdate(Intervento nuovoIntervento) async {
    var db = await ref.read(localdbProvider.future);
    await db.writeAsync((isar) {
      isar.interventos.put(nuovoIntervento);
    });

    var archividb = await ref.read(archividbProvider.future);
    await archividb.writeAsync((isar) {
      isar.interventos.put(nuovoIntervento);
    });
  }

  // no need to read from db. we work with the in memory data - see parameter keepAlive : true
  // Future<String?> getUltimoNumeroDocumento() async {
  //   var db = await ref.read(localdbProvider.future);
  //   var interventi = await db.interventos.where().findAllAsync();

  //   if (interventi.isNotEmpty) {
  //     interventi.sort((a, b) => b.dataDoc.compareTo(a.dataDoc));
  //     var ultimoIntervento = interventi.first;
  //     return ultimoIntervento.numDoc;
  //   } else {
  //     return null;
  //   }
  // }
}

// @Riverpod(keepAlive: true)
// class InterventiMemoryStateRepository extends _$InterventiMemoryStateRepository {
//   @override
//   Future<List<Intervento>> build() async {
//     var interventi = await ref.read(interventiDbOpRepositoryProvider.future);

//     return interventi;
//   }
//   }

@Riverpod(keepAlive: true)
class InterventiStateRepository extends _$InterventiStateRepository {
  @override
  Future<List<Intervento>> build() async {
    var interventoDataLimite =
        await ref.read(interventoDataLimiteRepositoryProvider.future);

    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss.SSS");
    DateTime interventoDataLimiteDate =
        dateFormat.parse(interventoDataLimite, true).toUtc();
    DateTime now = DateTime.now().toUtc();
    Duration difference = now.difference(interventoDataLimiteDate);

    if (difference.inMinutes >= 30) {
      var interventiStatus = await ref
          .read(interventiStatusApiProvider.call(interventoDataLimite).future);
      if (interventiStatus.isNotEmpty) {
        var interventi = await ref
            .read(interventiApiProvider.call(interventoDataLimite).future);

        var interventiDb = ref.read(interventiDbOpRepositoryProvider.notifier);
        await interventiDb.updateInterventiErp(interventi);
      }
      ref
          .read(interventoDataLimiteRepositoryProvider.notifier)
          .updateDataLimite();
    }

    var interventi = await ref.read(interventiDbOpRepositoryProvider.future);

    return interventi;
  }

  Future<void> deleteInterventoById(Intervento intervento) async {
    try {
      var interventiDb = ref.read(interventiDbOpRepositoryProvider.notifier);
      await interventiDb.deleteInterventoById(intervento);

      final nuoviInterventi =
          await ref.refresh(interventiStateRepositoryProvider.future);
      InterventiApertiDataSource(
          nuoviInterventi, ref as WidgetRef, context as BuildContext);

      print('Intervento eliminato con successo: ${intervento.idTestata}');
    } catch (e) {
      print('Error deleting Intervento: $e');
    }
  }

  void updateStateAfterDelete(Intervento intervento) {
    var interventi = state.asData!.value;
    interventi.removeWhere((i) => i.idTestata == intervento.idTestata);
    state = AsyncData(interventi);
  }

  Future<void> removeAllInterventi(
      List<Intervento> intervento, bool deleteLocalInterventi) async {
    try {
      var interventiDb = ref.read(interventiDbOpRepositoryProvider.notifier);
      await interventiDb.removeAllInterventi(intervento, deleteLocalInterventi);

      ref.invalidateSelf();
    } catch (e) {
      print('Error deleting Intervento: $e');
    }
  }

  Future<int?> findDocIdByNumDoc(String? numDoc) async {
    // we use the isDirty property to search localdb elements from the inmemory total collection
    var interventi = state.asData!.value.where((element) => element.isDirty);

    var intervento =
        interventi.firstWhereOrNull((element) => element.numDoc == numDoc);

    return intervento?.idTestata;
  }

  Future<void> updateInterventiErp(List<Intervento> erpinterventi) async {
    var interventiDb = ref.read(interventiDbOpRepositoryProvider.notifier);
    await interventiDb.updateInterventiErp(erpinterventi);

    var interventi = state.asData!.value;

    interventi.removeWhere((localIntervento) => !erpinterventi.any(
        (erpIntervento) =>
            erpIntervento.idTestata == localIntervento.idTestata));

    for (var erpIntervento in erpinterventi) {
      final index = interventi.indexWhere((localIntervento) =>
          localIntervento.idTestata == erpIntervento.idTestata);
      if (index == -1) {
        interventi.add(erpIntervento);
      }
    }

    state = AsyncData(interventi);
  }

  Future<void> updateInterventiCloseErp(List<Intervento> erpinterventi) async {
    // todo - Please check this logic. I think here you wanted to reload everything not just the erp interventi
    var interventiDb = ref.read(interventiDbOpRepositoryProvider.notifier);
    await interventiDb.updateInterventiErp(erpinterventi);

    // from what i see here is a sync of interventi from the erp. what should happen to the interventi in localdb with same id?
    var interventi = state.asData!.value;
    for (var ei in erpinterventi) {
      final index = interventi.indexWhere((i) => i.idTestata == ei.idTestata);
      if (index > -1) {
        interventi[index] = ei;
      } else {
        interventi.add(ei);
      }
    }

    state = AsyncData(interventi);
  }

  Future<void> filterInterventi(String fromDate, String toDate, String nDoc,
      String cliente, String rifMatricolaCliente, String telaio) async {
    var interventi = await ref.read(interventiDbOpRepositoryProvider.future);

    if (fromDate.isNotEmpty && toDate.isNotEmpty) {
      DateTime from = DateTime.parse(fromDate);
      DateTime to = DateTime.parse(toDate);

      interventi = interventi.where((intervento) {
        DateTime dataDoc = DateTime.parse(intervento.dataDoc.toString());

        return dataDoc.isAfter(from.subtract(const Duration(days: 1))) &&
            dataDoc.isBefore(to.add(const Duration(days: 1)));
      }).toList();
    }

    if (nDoc.isNotEmpty) {
      interventi = interventi
          .where((intervento) => intervento.numDoc?.contains(nDoc) ?? false)
          .toList();
    }
    if (cliente.isNotEmpty) {
      interventi = interventi
          .where((intervento) =>
              intervento.cliente?.descrizione?.contains(cliente) ?? false)
          .toList();
    }
    if (rifMatricolaCliente.isNotEmpty) {
      interventi = interventi
          .where((intervento) =>
              intervento.rifMatricolaCliente?.contains(rifMatricolaCliente) ??
              false)
          .toList();
    }
    if (telaio.isNotEmpty) {
      interventi = interventi
          .where((intervento) => intervento.telaio?.contains(telaio) ?? false)
          .toList();
    }

    state = AsyncData(interventi);
  }

  Future<void> addOrUpdate(Intervento intervento) async {
    var interventiDb = ref.read(interventiDbOpRepositoryProvider.notifier);
    await interventiDb.addOrUpdate(intervento);

    var interventi = state.asData!.value;
    final index =
        interventi.indexWhere((i) => i.idTestata == intervento.idTestata);
    if (index > -1) {
      interventi[index] = intervento;
    } else {
      interventi.add(intervento);
    }

    state = AsyncData(interventi);
  }

  Future<String?> getUltimoNumeroDocumento() async {
    // we use the isDirty property to search localdb elements from the inmemory total collection
    var interventi =
        state.asData!.value.where((element) => element.isDirty).toList();

    interventi.sort((a, b) => b.dataDoc.compareTo(a.dataDoc));
    var ultimoIntervento = interventi.firstOrNull;

    return ultimoIntervento?.numDoc;
  }

  // with this method you force the refresh of the provider (it will reload everything from db)
  void refresh() {
    ref.invalidateSelf();
  }
}
