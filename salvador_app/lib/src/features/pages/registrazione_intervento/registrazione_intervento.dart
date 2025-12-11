// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously, unnecessary_string_interpolations

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
// ignore: implementation_imports
import 'package:mailer/src/entities/address.dart' as prefix;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:salvador_task_management/src/config/providers.dart';
import 'package:salvador_task_management/src/features/pages/articoli/articoli_controller.dart';
import 'package:salvador_task_management/src/features/pages/interventi_aperti/intervento_aperto_state.dart';
import 'package:salvador_task_management/src/features/pages/registrazione_intervento/articoli_datasource.dart';
import 'package:salvador_task_management/src/features/pages/registrazione_intervento/articoli_datasource_columns.dart';
import 'package:salvador_task_management/src/models/articolo_model.dart';
import 'package:salvador_task_management/src/repository/elencomatrciole_api_repository.dart';
import 'package:salvador_task_management/src/models/intervento_model.dart';
import 'package:salvador_task_management/src/repository/add_righe_repository.dart';
import 'package:salvador_task_management/src/repository/allegati_marca_api_repository.dart';
import 'package:salvador_task_management/src/repository/allegati_modello_api_repository.dart';
import 'package:salvador_task_management/src/repository/disponibilita_articoli_api_repository.dart';
import 'package:salvador_task_management/src/repository/get_allegato_api_repository.dart';
import 'package:salvador_task_management/src/repository/interventi_api_repository.dart';
import 'package:salvador_task_management/src/repository/interventi_db_repository.dart';
import 'package:salvador_task_management/src/repository/invio_allegato_repository.dart';
import 'package:salvador_task_management/src/repository/movimento_magazzino.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore: must_be_immutable
class RegistrazioneInterventoPage extends ConsumerWidget {
  TimeOfDay? initialStartTime;
  TimeOfDay? initialEndTime;
  Articolo? articolo;
  Intervento? articoloIntervento;
  Riga? riga;
  double? nuovaQuantita;
  String? nuovaNota;
  double? quantity;
  String? notes;

  RegistrazioneInterventoPage({
    super.key,
    this.articolo,
    this.nuovaQuantita,
    this.articoloIntervento,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intervento = ref.watch(interventoApertoStateProvider);
    int numeroAllegati = AllegatiManager.allegatiTemporanei.length;
    final columns = articoliInterventiDataSourceColumns();
    const secureStorage = FlutterSecureStorage();

    double screenWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        String? dataDocFormatted;
        if (intervento != null) {
          dataDocFormatted =
              DateFormat('dd/MM/yyyy').format(intervento.dataDoc);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              (intervento.numDoc == null || intervento.numDoc == 'null')
                  ? 'INTERVENTO LOCALE'
                  : '${intervento.numDoc} - $dataDocFormatted - ${intervento.cliente?.descrizione ?? ''}',
            ),
            backgroundColor: const Color.fromARGB(255, 236, 201, 148),
          ),
          body: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (screenWidth < 600) ...[
                  _buildButton(
                    onPressed: () async {
                      _showAggiungiArticoloDialog(context, ref, intervento);
                    },
                    icon: Icons.construction,
                    label: 'Aggiungi Articolo',
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  const SizedBox(height: 20),
                  _buildButton(
                    onPressed: () async {
                      _showAggiungiNotaDialog(context, ref, riga);
                    },
                    icon: Icons.note_add,
                    label: 'Aggiungi Nota',
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  const SizedBox(height: 20),
                  _buildButton(
                    onPressed: () async {
                      List<PlatformFile> files = [];
                      _showAllegatiDialog(
                          context,
                          files,
                          intervento.rifMatricolaCliente ?? '',
                          ref,
                          intervento.idTestata);
                    },
                    icon: Icons.attach_file,
                    label: 'Allegati',
                    color: const Color.fromARGB(255, 255, 255, 255),
                    badgeCount: numeroAllegati,
                  ),
                  const SizedBox(height: 20),
                  _buildButton(
                    onPressed: () async {
                      _showMainDialog(
                          context,
                          ref,
                          intervento.rifMatricolaCliente ?? '',
                          intervento.matricola ?? '');
                    },
                    icon: Icons.file_copy,
                    label: 'Doc. Tecnica',
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  const SizedBox(height: 20),
                  Consumer(builder: ((context, ref, child) {
                    final intervento = ref.watch(interventoApertoStateProvider);

                    // final prefs =
                    //     ref.read(sharedPreferencesProvider).asData!.value;
                    List<Riga> righeList = intervento.righe.toList();

                    return Expanded(
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: intervento.righe.length,
                          itemBuilder: (context, index) {
                            final riga = intervento.righe[index];
                            return ListTile(
                              title: Text(
                                  '${riga.articolo?.codice ?? 'NOTA'} - ${riga.articolo?.descrizione ?? ''}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Operatore: ${riga.operatore ?? ''}'),
                                  Text(
                                      'Data: ${DateFormat('dd/MM/yyyy').format(riga.dtOraIns!)}'),
                                  Text('Quantità: ${riga.qta}'),
                                  Text('Note: ${riga.note ?? ''}'),
                                ],
                              ),
                              trailing: riga.idRiga == null
                                  ? TextButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                                title: const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Conferma',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                content: const Text(
                                                  'Vuoi eliminare la riga selezionata?',
                                                  textAlign: TextAlign.center,
                                                ),
                                                actions: <Widget>[
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Expanded(
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                                  foregroundColor:
                                                                      Colors.grey[
                                                                          300],
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                    side: const BorderSide(
                                                                        color: Colors
                                                                            .grey),
                                                                  ),
                                                                  textStyle: const TextStyle(
                                                                      color: Colors
                                                                          .black)),
                                                          child: const Text(
                                                              'No',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black)),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: ElevatedButton(
                                                          onPressed: () async {
                                                            righeList.removeAt(
                                                                index);
                                                            int indexCount =
                                                                index + 1;
                                                            await removeRiga(ref,
                                                                indexCount);
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            Navigator.pushReplacement(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (_) =>
                                                                        RegistrazioneInterventoPage()));
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                                  foregroundColor:
                                                                      Colors.grey[
                                                                          300],
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                    side: const BorderSide(
                                                                        color: Colors
                                                                            .grey),
                                                                  ),
                                                                  textStyle: const TextStyle(
                                                                      color: Colors
                                                                          .black)),
                                                          child: const Text(
                                                              'Si',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black)),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ]);
                                          },
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Icon(Icons.delete,
                                          color: Colors.red),
                                    )
                                  : null,
                              onTap: () {
                                // final idRiga = riga.riga;
                                final idRigaModify = riga.idRiga;
                                if (idRigaModify == null) {
                                  final String? codiceArticolo =
                                      riga.articolo?.codice;
                                  double qtaArt = riga.qta ?? 0.0;

                                  if ([
                                    'SMANCAR',
                                    'SMANCLI',
                                    'SMANEST',
                                    'SMANEST+40%',
                                    'SMANESTFES',
                                    'SMANFES',
                                    'SMANINT',
                                    'SMANSTD'
                                  ].contains(codiceArticolo ?? '')) {
                                    modifyDurataDialog(
                                        context, riga, nuovaQuantita, ref);
                                  } else {
                                    if (qtaArt == 0.0) {
                                      _showModifyNotaDialog(
                                          context, ref, riga, nuovaNota);
                                    } else if (qtaArt >= 1.0) {
                                      modifyDettagliDialog(
                                          context,
                                          articolo,
                                          intervento,
                                          ref,
                                          riga,
                                          nuovaQuantita,
                                          qtaArt,
                                          notes ?? '');
                                    }
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ),
                    );
                  }))
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildButton(
                          onPressed: () async {
                            _showAggiungiArticoloDialog(
                                context, ref, intervento);
                          },
                          icon: Icons.construction,
                          label: 'Aggiungi Articolo',
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildButton(
                          onPressed: () async {
                            _showAggiungiNotaDialog(context, ref, riga);
                          },
                          icon: Icons.note_add,
                          label: 'Aggiungi Nota',
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildButton(
                          onPressed: () async {
                            List<PlatformFile> files = [];
                            _showAllegatiDialog(
                                context,
                                files,
                                intervento.rifMatricolaCliente ?? '',
                                ref,
                                intervento.idTestata);
                          },
                          icon: Icons.attach_file,
                          label: 'Allegati',
                          color: const Color.fromARGB(255, 255, 255, 255),
                          badgeCount: numeroAllegati,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildButton(
                          onPressed: () async {
                            _showMainDialog(
                                context,
                                ref,
                                intervento.rifMatricolaCliente ?? '',
                                intervento.matricola ?? '');
                          },
                          icon: Icons.file_copy,
                          label: 'Doc. Tecnica',
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Consumer(builder: ((context, ref, child) {
                    final intervento = ref.watch(interventoApertoStateProvider);

                    final prefs =
                        ref.read(sharedPreferencesProvider).asData!.value;

                    return Expanded(
                      child: SfDataGrid(
                        source: ArticoliInterventoDataSource(
                            intervento, prefs, ref),
                        columns: columns,
                        columnWidthMode: ColumnWidthMode.fill,
                        headerGridLinesVisibility:
                            GridLinesVisibility.horizontal,
                        gridLinesVisibility: GridLinesVisibility.both,
                        allowEditing: true,
                        onCellTap: (details) {
                          final int idRiga = int.parse(
                              details.rowColumnIndex.rowIndex.toString());
                          final riga = intervento.righe.firstWhereOrNull(
                              (element) => element.riga == idRiga);

                          if (riga != null) {
                            final idRigaModify = riga.idRiga;

                            if (idRigaModify == null) {
                              double qtaArt = riga.qta ?? 0.0;

                              if ([
                                'SMANCAR',
                                'SMANCLI',
                                'SMANEST',
                                'SMANEST+40%',
                                'SMANESTFES',
                                'SMANFES',
                                'SMANINT',
                                'SMANSTD'
                              ].contains(riga.articolo?.codice ?? '')) {
                                modifyDurataDialog(
                                    context, riga, nuovaQuantita, ref);
                              } else {
                                if (qtaArt == 0.0) {
                                  _showModifyNotaDialog(
                                      context, ref, riga, nuovaNota);
                                } else if (qtaArt >= 1.0) {
                                  modifyDettagliDialog(
                                      context,
                                      articolo,
                                      intervento,
                                      ref,
                                      riga,
                                      nuovaQuantita,
                                      qtaArt,
                                      notes ?? '');
                                }
                              }
                            }
                          }
                        },
                      ),
                    );
                  }))
                ],
                SizedBox(
                  height: 60,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () async {
                            bool hasNullIdRiga = intervento.righe
                                .any((riga) => riga.idRiga == null);

                            if (!hasNullIdRiga) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Aggiungi una riga per chiudere la giornata'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            bool confirm = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Conferma',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: const Text(
                                    'Sei sicuro di voler chiudere la giornata?',
                                    textAlign: TextAlign.center,
                                  ),
                                  actions: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.grey[300],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                side: const BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              textStyle: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                            child: const Text('No',
                                                style: TextStyle(
                                                    color: Colors.black)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.grey[300],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                side: const BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              textStyle: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                            child: const Text('Si',
                                                style: TextStyle(
                                                    color: Colors.black)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm == true) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              );

                              try {
                                List<RigaInvio> righe = [];

                                for (var riga in intervento.righe) {
                                  RigaInvio nuovaRiga;

                                  if (riga.articolo?.codice == 'SMANCAR' ||
                                      riga.articolo?.codice == 'SMANCLI' ||
                                      riga.articolo?.codice == 'SMANEST' ||
                                      riga.articolo?.codice == 'SMANEST+40%' ||
                                      riga.articolo?.codice == 'SMANESTFES' ||
                                      riga.articolo?.codice == 'SMANFES' ||
                                      riga.articolo?.codice == 'SMANINT' ||
                                      riga.articolo?.codice == 'SMANSTD') {
                                    nuovaRiga = RigaInvio(
                                      id: null,
                                      idRiga: riga.idRiga,
                                      riga: riga.riga,
                                      descrizione: riga.descrizione,
                                      articolo: InterventoArticoloInvio(
                                        id: riga.articolo?.id,
                                        codice: riga.articolo?.codice,
                                        descrizione: riga.articolo?.descrizione,
                                      ),
                                      tipoRiga: null,
                                      qta: riga.qta,
                                      dtOraIni: riga.dtOraIni.toString(),
                                      dtOraFin: riga.dtOraFin.toString(),
                                      operatore: riga.operatore,
                                      note: riga.note,
                                      noteDaStampare: null,
                                      matricola: riga.matricola,
                                      dtOraIns: riga.dtOraIns.toString(),
                                      info: null,
                                      warning: null,
                                      error: null,
                                    );
                                  } else {
                                    nuovaRiga = RigaInvio(
                                      id: null,
                                      idRiga: riga.idRiga,
                                      riga: riga.riga,
                                      descrizione: riga.descrizione,
                                      articolo: InterventoArticoloInvio(
                                        id: riga.articolo?.id,
                                        codice: riga.articolo?.codice,
                                        descrizione: riga.articolo?.descrizione,
                                      ),
                                      tipoRiga: null,
                                      qta: riga.qta,
                                      dtOraIni: null,
                                      dtOraFin: null,
                                      operatore: riga.operatore,
                                      note: riga.note,
                                      noteDaStampare: null,
                                      matricola: riga.matricola,
                                      dtOraIns: riga.dtOraIns.toString(),
                                      info: null,
                                      warning: null,
                                      error: null,
                                    );
                                  }

                                  righe.add(nuovaRiga);
                                }

                                final result = await ref
                                    .read(addRigheApiRepositoryProvider)
                                    .updateRighe(
                                      idTestata: intervento.idTestata,
                                      numDoc: intervento.numDoc,
                                      dataDoc: intervento.dataDoc.toString(),
                                      note: intervento.note,
                                      matricola: intervento.matricola,
                                      telaio: intervento.telaio,
                                      rifMatricolaCliente:
                                          intervento.rifMatricolaCliente,
                                      contMatricola: intervento.contMatricola,
                                      righe: righe,
                                      status: 'SOS',
                                      idCliente: intervento.cliente?.id,
                                      codiceCliente: intervento.cliente?.codice,
                                      descrizioneCliente:
                                          intervento.cliente?.descrizione,
                                      idTipoDoc: intervento.tipoDoc?.id,
                                      codiceTipoDoc: intervento.tipoDoc?.codice,
                                      descrizioneTipoDoc:
                                          intervento.tipoDoc?.descrizione,
                                    );

                                final resultMap =
                                    result as Map<String, dynamic>;
                                final resultValue =
                                    resultMap['result'] as String;
                                final errorList =
                                    resultMap['errorList'] as List<dynamic>;

                                if (resultValue == 'OK') {
                                  final docId = resultMap['docId'] as int;

                                  var ultimaModifica = DateTime.now();
                                  final operatore = await secureStorage.read(
                                          key: 'username') ??
                                      '';

                                  var interventoApertoStateController = ref.read(
                                      interventoApertoStateProvider.notifier);

                                  await interventoApertoStateController
                                      .updateInterventoModifica(
                                          operatoreModifica: operatore,
                                          ultimaModifica: ultimaModifica,
                                          status: 'SOS');

                                  await interventoApertoStateController.updateDocId(
                                      docId: docId);

                                  //_deleteIntervento(intervento, ref);
// todo - check this
                                  var interventiDbProvider = ref.read(
                                      interventiStateRepositoryProvider
                                          .notifier);
                                  await interventiDbProvider
                                      .deleteInterventoById(intervento);

                                  Navigator.of(context).pop();

                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  );

                                  var interventi = await ref.read(
                                      interventiApiProvider.call("").future);

                                  ref
                                      .read(interventiStateRepositoryProvider
                                          .notifier)
                                      .removeAllInterventi(interventi, false);

                                  ref
                                      .read(interventiStateRepositoryProvider
                                          .notifier)
                                      .updateInterventiErp(interventi);

                                  Navigator.of(context).pop();

                                  chiudiGiornata = true;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Documento registrato con successo.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                } else {
                                  Navigator.of(context).pop();

                                  final errorMessage = errorList.isNotEmpty
                                      ? errorList.first.toString()
                                      : 'Errore sconosciuto';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Errore: $errorMessage'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                Navigator.of(context).pop();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Si è verificato un errore: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            textStyle: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            minimumSize: const Size(double.infinity, 60),
                          ),
                          icon: const Icon(Icons.close),
                          label: const Text('Chiudi giornata'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () async {
                            bool hasNullIdRiga = intervento.righe
                                .any((riga) => riga.idRiga == null);

                            if (!hasNullIdRiga) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Aggiungi una riga per completare l\'intervento'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            bool confirm = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Conferma',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: const Text(
                                    'Sei sicuro di voler completare l\'intervento?',
                                    textAlign: TextAlign.center,
                                  ),
                                  actions: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.grey[300],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                side: const BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              textStyle: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                            child: const Text('No',
                                                style: TextStyle(
                                                    color: Colors.black)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.grey[300],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                side: const BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              textStyle: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                            child: const Text('Si',
                                                style: TextStyle(
                                                    color: Colors.black)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm == true) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              );

                              try {
                                List<RigaInvio> righe = [];

                                for (var riga in intervento.righe) {
                                  RigaInvio nuovaRiga;

                                  if (riga.articolo?.codice == 'SMANCAR' ||
                                      riga.articolo?.codice == 'SMANCLI' ||
                                      riga.articolo?.codice == 'SMANEST' ||
                                      riga.articolo?.codice == 'SMANEST+40%' ||
                                      riga.articolo?.codice == 'SMANESTFES' ||
                                      riga.articolo?.codice == 'SMANFES' ||
                                      riga.articolo?.codice == 'SMANINT' ||
                                      riga.articolo?.codice == 'SMANSTD') {
                                    nuovaRiga = RigaInvio(
                                      id: null,
                                      idRiga: riga.idRiga,
                                      riga: riga.riga,
                                      descrizione: riga.descrizione,
                                      articolo: InterventoArticoloInvio(
                                        id: riga.articolo?.id,
                                        codice: riga.articolo?.codice,
                                        descrizione: riga.articolo?.descrizione,
                                      ),
                                      tipoRiga: null,
                                      qta: riga.qta,
                                      dtOraIni: riga.dtOraIni.toString(),
                                      dtOraFin: riga.dtOraFin.toString(),
                                      operatore: riga.operatore,
                                      note: riga.note,
                                      noteDaStampare: null,
                                      matricola: riga.matricola,
                                      dtOraIns: riga.dtOraIns.toString(),
                                      info: null,
                                      warning: null,
                                      error: null,
                                    );
                                  } else {
                                    nuovaRiga = RigaInvio(
                                      id: null,
                                      idRiga: riga.idRiga,
                                      riga: riga.riga,
                                      descrizione: riga.descrizione,
                                      articolo: InterventoArticoloInvio(
                                        id: riga.articolo?.id,
                                        codice: riga.articolo?.codice,
                                        descrizione: riga.articolo?.descrizione,
                                      ),
                                      tipoRiga: null,
                                      qta: riga.qta,
                                      dtOraIni: null,
                                      dtOraFin: null,
                                      operatore: riga.operatore,
                                      note: riga.note,
                                      noteDaStampare: null,
                                      matricola: riga.matricola,
                                      dtOraIns: riga.dtOraIns.toString(),
                                      info: null,
                                      warning: null,
                                      error: null,
                                    );
                                  }

                                  righe.add(nuovaRiga);
                                }

                                final result = await ref
                                    .read(addRigheApiRepositoryProvider)
                                    .updateRighe(
                                      idTestata: intervento.idTestata,
                                      numDoc: intervento.numDoc,
                                      dataDoc: intervento.dataDoc.toString(),
                                      note: intervento.note,
                                      matricola: intervento.matricola,
                                      telaio: intervento.telaio,
                                      rifMatricolaCliente:
                                          intervento.rifMatricolaCliente,
                                      contMatricola: intervento.contMatricola,
                                      righe: righe,
                                      status: 'CHI',
                                      idCliente: intervento.cliente?.id,
                                      codiceCliente: intervento.cliente?.codice,
                                      descrizioneCliente:
                                          intervento.cliente?.descrizione,
                                      idTipoDoc: intervento.tipoDoc?.id,
                                      codiceTipoDoc: intervento.tipoDoc?.codice,
                                      descrizioneTipoDoc:
                                          intervento.tipoDoc?.descrizione,
                                    );

                                final resultMap =
                                    result as Map<String, dynamic>;
                                final resultValue =
                                    resultMap['result'] as String;
                                final errorList =
                                    resultMap['errorList'] as List<dynamic>;

                                if (resultValue == 'OK') {
                                  final docId = resultMap['docId'] as int;

                                  var ultimaModifica = DateTime.now();
                                  final operatore = await secureStorage.read(
                                          key: 'username') ??
                                      '';
                                  var interventiDbProviderIntervento = ref.read(
                                      interventoApertoStateProvider.notifier);
                                  await interventiDbProviderIntervento
                                      .updateInterventoModifica(
                                          operatoreModifica: operatore,
                                          ultimaModifica: ultimaModifica,
                                          status: 'CHI');

                                  var interventiDbProviderDocId = ref.read(
                                      interventoApertoStateProvider.notifier);
                                  await interventiDbProviderDocId.updateDocId(
                                      docId: docId);

                                  //_deleteIntervento(intervento, ref);

                                  var interventiDbProvider = ref.read(
                                      interventiStateRepositoryProvider
                                          .notifier);
                                  await interventiDbProvider
                                      .deleteInterventoById(intervento);

                                  Navigator.of(context).pop();

                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  );

                                  var interventi = await ref.read(
                                      interventiApiProvider.call("").future);

                                  ref
                                      .read(interventiStateRepositoryProvider
                                          .notifier)
                                      .removeAllInterventi(interventi, false);

                                  ref
                                      .read(interventiStateRepositoryProvider
                                          .notifier)
                                      .updateInterventiErp(interventi);

                                  Navigator.of(context).pop();

                                  chiudiGiornata = true;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Documento registrato con successo.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                } else {
                                  Navigator.of(context).pop();

                                  final errorMessage = errorList.isNotEmpty
                                      ? errorList.first.toString()
                                      : 'Errore sconosciuto';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Errore: $errorMessage'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                Navigator.of(context).pop();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Si è verificato un errore: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            textStyle: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            minimumSize: const Size(double.infinity, 60),
                          ),
                          icon: const Icon(Icons.check),
                          label: const Text('Completa Intervento'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> removeRiga(WidgetRef ref, int index) async {
    await ref.read(interventoApertoStateProvider.notifier).removeRiga(index);
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    double height = 50.0,
    int badgeCount = 0,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: buttonStyle.copyWith(
          backgroundColor: WidgetStateProperty.all(color),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.black),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            if (badgeCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  final buttonStyle = TextButton.styleFrom(
    foregroundColor: Colors.black,
    textStyle: const TextStyle(
      fontSize: 15.0,
      fontWeight: FontWeight.bold,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
      side: const BorderSide(
        color: Colors.black,
        width: 1,
      ),
    ),
  );

  bool chiudiGiornata = false;

  Future<void> _showAllegatiDialog(
    BuildContext context,
    List<PlatformFile> files,
    String rifMatricolaCliente,
    WidgetRef ref,
    int idTestata,
  ) async {
    String descrizioneAllegato = '';
    Intervento? intervento;
    const secureStorage = FlutterSecureStorage();

    var interventi = await ref.read(interventiStateRepositoryProvider.future);

    intervento = interventi
        .firstWhereOrNull((intervento) => intervento.idTestata == idTestata);

    if (intervento == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.dangerous),
                SizedBox(width: 2),
                Text('Errore'),
              ],
            ),
            content: const Text('Impossibile trovare l\'intervento'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    Riga? riga;
    int? docId;

    if (idTestata < 0) {
      if (!chiudiGiornata) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.dangerous),
                  SizedBox(width: 2),
                  Text('Attenzione'),
                ],
              ),
              content: const Text(
                  "Devi chiudere la giornata o completare l'intervento prima di poter aggiungere allegati"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }
      riga = intervento.righe
          .lastWhereOrNull((riga) => riga.idTestata == idTestata);
      docId = riga?.docId;
    } else {
      docId = intervento.idTestata;
    }

    AllegatiManager.allegatiTemporanei.addAll(files);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.attach_file),
                  SizedBox(width: 2),
                  Text('ALLEGATI'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (AllegatiManager.allegatiTemporanei.isNotEmpty) ...[
                    for (int i = 0;
                        i < AllegatiManager.allegatiTemporanei.length;
                        i++)
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageViewScreen(
                                  filePath: AllegatiManager
                                      .allegatiTemporanei[i].path!),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(AllegatiManager
                                    .allegatiTemporanei[i].name)),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  AllegatiManager.allegatiTemporanei
                                      .removeAt(i);
                                });
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10),
                  ],
                  Align(
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: () async {
                        final result = await showDialog<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              title: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Aggiungi Allegato',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              children: <Widget>[
                                SimpleDialogOption(
                                  onPressed: () async {
                                    final imagePicker = ImagePicker();
                                    final XFile? pickedImage =
                                        await imagePicker.pickImage(
                                      source: ImageSource.camera,
                                    );
                                    if (pickedImage != null) {
                                      File newFile = File(pickedImage.path);
                                      PlatformFile platformFile = PlatformFile(
                                        name: pickedImage.path.split('/').last,
                                        path: pickedImage.path,
                                        size: await newFile.length(),
                                      );
                                      setState(() {
                                        AllegatiManager.allegatiTemporanei
                                            .add(platformFile);
                                      });
                                      Navigator.pop(context, 'ScattaFoto');
                                    }
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.camera_alt),
                                      SizedBox(width: 8.0),
                                      Text('Scatta Foto',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontStyle: FontStyle.italic)),
                                    ],
                                  ),
                                ),
                                SimpleDialogOption(
                                  onPressed: () async {
                                    final result =
                                        await FilePicker.platform.pickFiles(
                                      allowMultiple: true,
                                      type: FileType.custom,
                                      allowedExtensions: [
                                        'jpg',
                                        'pdf',
                                        'doc',
                                        'docx'
                                      ],
                                    );

                                    if (result != null) {
                                      setState(() {
                                        AllegatiManager.allegatiTemporanei
                                            .addAll(result.files);
                                      });
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.file_copy),
                                      SizedBox(width: 8.0),
                                      Text('Scegli file',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontStyle: FontStyle.italic)),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (result == 'ScattaFoto') {
                        } else if (result == 'VisualizzaAllegati') {}
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Descrizione Allegato',
                    ),
                    maxLength: 500,
                    maxLines: 5,
                    onChanged: (value) {
                      descrizioneAllegato = value;
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: const BorderSide(color: Colors.grey),
                          ),
                        ),
                        child: const Text(
                          'Annulla',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          for (var allegato
                              in AllegatiManager.allegatiTemporanei) {
                            File file = File(allegato.path!);
                            List<int> fileBytes = await file.readAsBytes();
                            String base64File = base64Encode(fileBytes);
                            String extension = path
                                .extension(allegato.name)
                                .toUpperCase()
                                .substring(1);

                            String formattedDate =
                                DateFormat('yyyy-MM-dd HH:mm:ss')
                                    .format(DateTime.now());

                            var ultimaModifica = DateTime.now();
                            final operatore =
                                await secureStorage.read(key: 'username') ?? '';
                            var interventiDbProvider = ref
                                .read(interventoApertoStateProvider.notifier);
                            await interventiDbProvider.updateInterventoModifica(
                                operatoreModifica: operatore,
                                ultimaModifica: ultimaModifica);

                            final result = await ref
                                .read(invioAllegatoApiRepositoryProvider)
                                .sendAttachment(
                                  docId: docId,
                                  tipoAll: 'OR',
                                  nomeAllegato: allegato.name,
                                  descrizioneAllegato: descrizioneAllegato,
                                  tipoAllegato: extension,
                                  fileSize: allegato.size.toString(),
                                  created: formattedDate,
                                  base64File: base64File,
                                );

                            if (result != null) {
                              final resultMap = result as Map<String, dynamic>;
                              final resultValue = resultMap['result'] as String;

                              if (resultValue == 'OK') {
                                AllegatiManager.allegatiTemporanei.clear();
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Allegato inviato'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Errore durante l\'invio dell\'allegato.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: const BorderSide(color: Colors.grey),
                          ),
                        ),
                        child: const Text(
                          'Invia',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMainDialog(BuildContext context, WidgetRef ref,
      String rifMatricolaCliente, String codice) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
            width: 300,
            height: 300,
            child: SimpleDialog(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Scegli Opzione',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              children: [
                SimpleDialogOption(
                  onPressed: () async {
                    final result = await ref
                        .read(elencoMatricoleApiAllegatiRepositoryProvider)
                        .getMatricolaAllegato(
                            utente: 'ADMIN',
                            rifMatricolaCliente: rifMatricolaCliente);

                    if (result != null) {
                      for (final item in result) {
                        if (item is Map<String, dynamic>) {
                          final List<dynamic>? allegati =
                              item['allegatiMarca'] as List<dynamic>?;

                          if (allegati != null && allegati.isNotEmpty) {
                            final List<Widget> allegatiWidgets = [];

                            for (final allegato in allegati) {
                              final idAllegato = allegato['id'] as int?;
                              final nomeAllegato = allegato['nome'] as String?;
                              final info1 = allegato['info1'] as String? ?? '';
                              final info2 = allegato['info2'] as String? ?? '';

                              if (idAllegato != null && nomeAllegato != null) {
                                final idAllegatoResult = await ref
                                    .read(getAllegatoApiRepositoryProvider)
                                    .getAllegato(
                                        utente: 'ADMIN',
                                        idAllegato: idAllegato);

                                if (idAllegatoResult != null &&
                                    idAllegatoResult is List) {
                                  allegatiWidgets.add(
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                              '$nomeAllegato $info1 $info2'),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.file_open),
                                          onPressed: () async {
                                            _showPdfPreview(
                                              context,
                                              idAllegatoResult[0]['base64File'],
                                              nomeAllegato,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }
                            }

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SizedBox(
                                  width: 300,
                                  height: 500,
                                  child: AlertDialog(
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$rifMatricolaCliente',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 10),
                                        Column(
                                          children: allegatiWidgets,
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor:
                                                    Colors.grey[300],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  side: const BorderSide(
                                                      color: Colors.grey),
                                                ),
                                                textStyle: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                              child: const Text(
                                                'Chiudi',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SizedBox(
                                  width: 300,
                                  height: 500,
                                  child: AlertDialog(
                                    title: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'ATTENZIONE',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: const Text(
                                      'Non ci sono allegati disponibili.',
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        }
                      }
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car_filled),
                      SizedBox(width: 8.0),
                      Text('MARCA',
                          style: TextStyle(
                              color: Colors.black,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                SimpleDialogOption(
                  onPressed: () async {
                    final result = await ref
                        .read(elencoMatricoleApiAllegatiRepositoryProvider)
                        .getMatricolaAllegato(
                            utente: 'ADMIN',
                            rifMatricolaCliente: rifMatricolaCliente);

                    if (result != null) {
                      for (final item in result) {
                        if (item is Map<String, dynamic>) {
                          final List<dynamic>? allegati =
                              item['allegatiModello'] as List<dynamic>?;

                          if (allegati != null && allegati.isNotEmpty) {
                            final List<Widget> allegatiWidgets = [];

                            for (final allegato in allegati) {
                              final idAllegato = allegato['id'] as int?;
                              final nomeAllegato = allegato['nome'] as String?;
                              final info1 = allegato['info1'] as String? ?? '';
                              final info2 = allegato['info2'] as String? ?? '';

                              if (idAllegato != null && nomeAllegato != null) {
                                final idAllegatoResult = await ref
                                    .read(getAllegatoApiRepositoryProvider)
                                    .getAllegato(
                                        utente: 'ADMIN',
                                        idAllegato: idAllegato);

                                if (idAllegatoResult != null &&
                                    idAllegatoResult is List) {
                                  allegatiWidgets.add(
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                              nomeAllegato + info1 + info2),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.file_open),
                                          onPressed: () async {
                                            _showPdfPreview(
                                              context,
                                              idAllegatoResult[0]['base64File'],
                                              nomeAllegato,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }
                            }

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$rifMatricolaCliente',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Column(
                                        children: allegatiWidgets,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.grey[300],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                side: const BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              textStyle: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                            child: const Text(
                                              'Chiudi',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'ATTENZIONE',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: const Text(
                                    'Non ci sono allegati disponibili.',
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        }
                      }
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car_filled),
                      SizedBox(width: 8.0),
                      Text('MODELLO',
                          style: TextStyle(
                              color: Colors.black,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                SimpleDialogOption(
                  onPressed: () async {
                    final result = await ref
                        .read(elencoMatricoleApiAllegatiRepositoryProvider)
                        .getMatricolaAllegato(
                            utente: 'ADMIN',
                            rifMatricolaCliente: rifMatricolaCliente);

                    if (result != null) {
                      for (final item in result) {
                        if (item is Map<String, dynamic>) {
                          final List<dynamic>? allegati =
                              item['allegati'] as List<dynamic>?;

                          if (allegati != null && allegati.isNotEmpty) {
                            final List<Widget> allegatiWidgets = [];

                            for (final allegato in allegati) {
                              final idAllegato = allegato['id'] as int?;
                              final nomeAllegato = allegato['nome'] as String?;
                              final info1 = allegato['info1'] as String? ?? '';
                              final info2 = allegato['info2'] as String? ?? '';

                              if (idAllegato != null && nomeAllegato != null) {
                                final idAllegatoResult = await ref
                                    .read(getAllegatoApiRepositoryProvider)
                                    .getAllegato(
                                        utente: 'ADMIN',
                                        idAllegato: idAllegato);

                                if (idAllegatoResult != null &&
                                    idAllegatoResult is List) {
                                  allegatiWidgets.add(
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                              nomeAllegato + info1 + info2),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.file_open),
                                          onPressed: () async {
                                            _showPdfPreview(
                                              context,
                                              idAllegatoResult[0]['base64File'],
                                              nomeAllegato,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }
                            }

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$rifMatricolaCliente',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Column(
                                        children: allegatiWidgets,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.grey[300],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                side: const BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              textStyle: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                            child: const Text(
                                              'Chiudi',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'ATTENZIONE',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: const Text(
                                    'Non ci sono allegati disponibili.',
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        }
                      }
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car_filled),
                      SizedBox(width: 8.0),
                      Text('TARGA',
                          style: TextStyle(
                              color: Colors.black,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                SimpleDialogOption(
                  onPressed: () async {
                    final result = await ref
                        .read(elencoMatricoleApiAllegatiRepositoryProvider)
                        .getMatricoleAllegato(utente: 'ADMIN');

                    if (result != null) {
                      List<Map<String, dynamic>> matricoleFiglie = [];

                      // Filtra le matricole figlie che hanno 'rifMatricolaPadre' uguale a 'rifMatricolaCliente'
                      for (final item in result) {
                        if (item is Map<String, dynamic>) {
                          final rifMatricolaPadre =
                              item['rifMatrPadre'] as String?;
                          if (rifMatricolaPadre != null &&
                              rifMatricolaPadre == codice) {
                            matricoleFiglie.add(item);
                          }
                        }
                      }

                      if (matricoleFiglie.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              title: const Text("Seleziona Matricola"),
                              children: [
                                ...matricoleFiglie.map((matricola) {
                                  return SimpleDialogOption(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _showMarcaModelloDialog(context, ref,
                                          matricola, rifMatricolaCliente);
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(Icons.directions_car_filled),
                                        const SizedBox(width: 8.0),
                                        Text(
                                            'MATRICOLA FIGLIA: ${matricola['codice']}',
                                            style: const TextStyle(
                                                color: Colors.black)),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            );
                          },
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SizedBox(
                              width: 300,
                              height: 500,
                              child: AlertDialog(
                                title: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'ATTENZIONE',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                content: const Text(
                                  'Non ci sono allegati disponibili.',
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car_filled),
                      SizedBox(width: 8.0),
                      Text('MATRICOLE FIGLIE',
                          style: TextStyle(
                              color: Colors.black,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ],
            ));
      },
    );
  }

  void _showMarcaModelloDialog(BuildContext context, WidgetRef ref,
      Map<String, dynamic> matricola, String rifMatricolaCliente) async {
    //final List<Widget> marcaWidgets = [];
    final List<Widget> modelloWidgets = [];

    // Mostra un alert generico
    void showAlert(BuildContext context, String title, String message) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Scegli Opzione',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          children: [
            SimpleDialogOption(
              onPressed: () async {
                // Mostra il dialogo di caricamento
                showDialog(
                  context: context,
                  barrierDismissible:
                      false, // Evita la chiusura toccando al di fuori
                  builder: (BuildContext context) {
                    return const AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RotatingHourglass(),
                          SizedBox(height: 16.0),
                          Text('Caricamento in corso...'),
                        ],
                      ),
                    );
                  },
                );

                try {
                  final marca = matricola['marca'] as String?;
                  if (marca != null) {
                    final marcaResult = await ref
                        .read(allegatiMarcaApiRepositoryProvider)
                        .getMarca(codice: marca);

                    if (marcaResult != null && marcaResult is List) {
                      final List<dynamic>? allegati =
                          marcaResult[0]['allegati'] as List<dynamic>?;
                      if (allegati != null && allegati.isNotEmpty) {
                        final List<Widget> marcaWidgets = [];

                        for (final allegato in allegati) {
                          final idAllegato = allegato['id'] as int?;
                          final nomeAllegato = allegato['nome'] as String?;
                          final info1 = allegato['info1'] as String? ?? '';
                          final info2 = allegato['info2'] as String? ?? '';

                          if (idAllegato != null && nomeAllegato != null) {
                            final idAllegatoResult = await ref
                                .read(getAllegatoApiRepositoryProvider)
                                .getAllegato(
                                  utente: 'ADMIN',
                                  idAllegato: idAllegato,
                                );

                            if (idAllegatoResult != null &&
                                idAllegatoResult is List) {
                              marcaWidgets.add(
                                Row(
                                  children: [
                                    Expanded(
                                      child:
                                          Text('$nomeAllegato $info1 $info2'),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.file_open),
                                      onPressed: () async {
                                        _showPdfPreview(
                                          context,
                                          idAllegatoResult[0]['base64File'],
                                          nomeAllegato,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        }

                        // Chiudi il dialogo di caricamento
                        Navigator.of(context).pop();

                        // Mostra il dialogo con gli allegati
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$rifMatricolaCliente',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Column(
                                    children: marcaWidgets,
                                  ),
                                ],
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.grey[300],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            side: const BorderSide(
                                                color: Colors.grey),
                                          ),
                                          textStyle: const TextStyle(
                                              color: Colors.black),
                                        ),
                                        child: const Text(
                                          'Chiudi',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        Navigator.of(context)
                            .pop(); // Chiudi il dialogo di caricamento
                        showAlert(context, 'ATTENZIONE',
                            'Non ci sono allegati disponibili per la marca.');
                      }
                    } else {
                      Navigator.of(context)
                          .pop(); // Chiudi il dialogo di caricamento
                      showAlert(context, 'ERRORE',
                          'Non esiste la marca nel gestionale.');
                    }
                  }
                } catch (e) {
                  Navigator.of(context)
                      .pop(); // Chiudi il dialogo di caricamento in caso di errore
                  showAlert(context, 'ERRORE',
                      'Si è verificato un errore durante il caricamento.');
                }
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car_filled),
                  SizedBox(width: 8.0),
                  Text('MARCA',
                      style: TextStyle(
                          color: Colors.black, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () async {
// Mostra il dialogo di caricamento
                showDialog(
                  context: context,
                  barrierDismissible:
                      false, // Evita la chiusura toccando al di fuori
                  builder: (BuildContext context) {
                    return const AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RotatingHourglass(),
                          SizedBox(height: 16.0),
                          Text('Caricamento in corso...'),
                        ],
                      ),
                    );
                  },
                );

                try {
                  final modello = matricola['modello'] as String?;
                  if (modello != null) {
                    final modelloResult = await ref
                        .read(allegatiModelloApiRepositoryProvider)
                        .getModello(codice: modello);

                    if (modelloResult != null && modelloResult is List) {
                      final List<dynamic>? allegati =
                          modelloResult[0]['allegati'] as List<dynamic>?;
                      if (allegati != null && allegati.isNotEmpty) {
                        for (final allegato in allegati) {
                          final idAllegato = allegato['id'] as int?;
                          final nomeAllegato = allegato['nome'] as String?;
                          final info1 = allegato['info1'] as String? ?? '';
                          final info2 = allegato['info2'] as String? ?? '';

                          if (idAllegato != null && nomeAllegato != null) {
                            final idAllegatoResult = await ref
                                .read(getAllegatoApiRepositoryProvider)
                                .getAllegato(
                                  utente: 'ADMIN',
                                  idAllegato: idAllegato,
                                );

                            if (idAllegatoResult != null &&
                                idAllegatoResult is List) {
                              modelloWidgets.add(
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                            '$nomeAllegato $info1 $info2')),
                                    IconButton(
                                      icon: const Icon(Icons.file_open),
                                      onPressed: () async {
                                        _showPdfPreview(
                                          context,
                                          idAllegatoResult[0]['base64File'],
                                          nomeAllegato,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        }

                        // Chiudi il dialogo di caricamento prima di mostrare quello con i dati
                        Navigator.of(context).pop();

                        // Mostra il dialogo con gli allegati
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$rifMatricolaCliente',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Column(
                                    children: modelloWidgets,
                                  ),
                                ],
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.grey[300],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            side: const BorderSide(
                                                color: Colors.grey),
                                          ),
                                          textStyle: const TextStyle(
                                              color: Colors.black),
                                        ),
                                        child: const Text(
                                          'Chiudi',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        Navigator.of(context)
                            .pop(); // Chiudi il dialogo di caricamento
                        showAlert(context, 'ATTENZIONE',
                            'Non ci sono allegati disponibili per il modello.');
                      }
                    } else {
                      Navigator.of(context)
                          .pop(); // Chiudi il dialogo di caricamento
                      showAlert(context, 'ERRORE',
                          'Non esiste il modello nel gestionale.');
                    }
                  }
                } catch (e) {
                  Navigator.of(context)
                      .pop(); // Chiudi il dialogo di caricamento in caso di errore
                  showAlert(context, 'ERRORE',
                      'Si è verificato un errore durante il caricamento.');
                }
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.build),
                  SizedBox(width: 8.0),
                  Text('MODELLO',
                      style: TextStyle(
                          color: Colors.black, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPdfPreview(
      BuildContext context, String base64File, String filename) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            PdfPreviewPage(base64File: base64File, fileName: filename),
      ),
    );
  }

  void _showAggiungiArticoloDialog(
      BuildContext context, WidgetRef ref, Intervento intervento) {
    String searchQuery = '';
    final TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.construction),
                  SizedBox(width: 2),
                  Text('Articoli'),
                ],
              ),
              content: SizedBox(
                width: 400,
                height: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            autofocus: true,
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                              ref
                                  .read(articoliControllerProvider.notifier)
                                  .applyFilterArticoli(filterText: value);
                            },
                            onSubmitted: (_) async {
                              _aggiungiArticoloIfSingle(
                                  context, ref, intervento);
                            },
                            decoration: InputDecoration(
                              labelText: 'Cerca per codice o descrizione',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide:
                                    const BorderSide(color: Colors.orange),
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          onPressed: () async {
                            String? qrCode = await scanQRCode(context);
                            if (qrCode != null) {
                              searchController.text = qrCode;
                              setState(() {
                                searchQuery = qrCode;
                              });
                              ref
                                  .read(articoliControllerProvider.notifier)
                                  .applyFilterArticoli(filterText: qrCode);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ref.watch(articoliControllerProvider).when(
                          data: (data) {
                            if (searchQuery.isEmpty) {
                              return const SizedBox();
                            } else {
                              final filteredData = data.where((articolo) {
                                final codice =
                                    articolo.codice.toString().toLowerCase();
                                final descrizione = articolo.descrizione
                                    .toString()
                                    .toLowerCase();
                                final searchWords =
                                    searchQuery.toLowerCase().split(' ');
                                return searchWords.every((word) =>
                                    codice.contains(word) ||
                                    descrizione.contains(word));
                              }).toList();

                              return Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredData.length,
                                  itemBuilder: (context, index) {
                                    var articolo = filteredData[index];
                                    return ListTile(
                                      title: Text(articolo.descrizione),
                                      subtitle: Text(articolo.codice),
                                      onTap: () {
                                        final intervento = ref.read(
                                            interventoApertoStateProvider);
                                        _showAggiungiDettagliDialog(
                                            context, articolo, intervento, ref);
                                      },
                                    );
                                  },
                                ),
                              );
                            }
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stackTrace) {
                            return Text('Error: $error');
                          },
                        ),
                  ],
                ),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      side: WidgetStateProperty.all<BorderSide>(
                        const BorderSide(color: Colors.grey),
                      ),
                      minimumSize: WidgetStateProperty.all<Size>(
                          const Size(double.infinity, 60)),
                    ),
                    child: const Text(
                      'Chiudi',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(FocusNode());
      searchController.clear();
    });
  }

  Future<String?> scanQRCode(BuildContext context) async {
    // ignore: unused_local_variable
    String? scannedCode;
    Completer<String?> completer = Completer<String?>();

    final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
    QRViewController? qrController;

    await showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code, size: 28),
              SizedBox(width: 8),
              Text('Scan QR Code'),
            ],
          ),
          content: SizedBox(
            width: 400,
            height: 400,
            child: QRView(
              key: qrKey,
              onQRViewCreated: (controller) {
                qrController = controller;
                qrController!.scannedDataStream.listen((scanData) {
                  if (!completer.isCompleted) {
                    completer.complete(scanData.code);
                    scannedCode = scanData.code;
                    Navigator.pop(context);
                  }
                });
              },
            ),
          ),
          actions: <Widget>[
            SizedBox(
              width: double.infinity,
              child: TextButton(
                child: const Text('Annulla'),
                onPressed: () {
                  if (!completer.isCompleted) {
                    completer.complete(null);
                  }
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );

    qrController?.dispose();

    return completer.future;
  }

  void _aggiungiArticoloIfSingle(
      BuildContext context, WidgetRef ref, Intervento intervento) async {
    // final filteredData = ref.watch(articoliControllerProvider);
    // if (filteredData is AsyncData<List<Map<String, dynamic>>>) {
    //   if (filteredData.value.length == 1) {
    //     _showAggiungiDettagliDialog(context, filteredData.value.first, ref);
    //   }
    // }

    final filteredData = await ref.watch(articoliControllerProvider.future);
    final articolo = filteredData.first;
    _showAggiungiDettagliDialog(context, articolo, intervento, ref);
  }

  Future<void> addRiga(Articolo articolo, WidgetRef ref, Map<String, dynamic> params,
      Map<String, dynamic> resultMapDocId) async {
    await ref
        .read(interventoApertoStateProvider.notifier)
        .addRiga(articolo, params, resultMapDocId);
  }

  Future<void> addRigaQuantita(Articolo? articolo, WidgetRef ref,
      Map<String, dynamic> params, Map<String, dynamic> resultMapDocId) async {
    await ref
        .read(interventoApertoStateProvider.notifier)
        .addRigaQuantita(articolo, params, resultMapDocId);
  }

  Future<void> addNota(WidgetRef ref, Map<String, dynamic> params) async {
    await ref.read(interventoApertoStateProvider.notifier).addOrUpdateNota(params);
  }

  Future<void> updateNota(Riga riga, String? nuovaNota, WidgetRef ref) async {
    await ref
        .read(interventoApertoStateProvider.notifier)
        .updateRigaNota(riga, nuovaNota);
  }

  void _showAggiungiDettagliDialog(BuildContext context, Articolo articolo,
      Intervento intervento, WidgetRef ref) async {
    if ([
      'SMANCAR',
      'SMANCLI',
      'SMANEST',
      'SMANEST+40%',
      'SMANESTFES',
      'SMANFES',
      'SMANINT',
      'SMANSTD'
    ].contains(articolo.codice)) {
      _showDurataDialog(context, articolo, intervento, ref);
    } else {
      _showQuantitaDialog(context, articolo, intervento, ref);
    }
  }

  String calculateDuration(TimeOfDay start, TimeOfDay end) {
    DateTime startDate = DateTime(2022, 1, 1, start.hour, start.minute);
    DateTime endDate = DateTime(2022, 1, 1, end.hour, end.minute);

    Duration difference = endDate.difference(startDate);
    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);

    if (minutes <= 14) {
      minutes = 0;
    } else if (minutes <= 44) {
      minutes = 30;
    } else {
      minutes = 0;
      hours++;
    }

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  void _showDurataDialog(BuildContext context, Articolo articolo,
      Intervento intervento, WidgetRef ref) async {
    TimeOfDay? startTime = initialStartTime;
    TimeOfDay? endTime = initialEndTime;
    int quantity = 1;
    String notes = '';
    const secureStorage = FlutterSecureStorage();
    // TextEditingController notesController = TextEditingController();
    TextEditingController startTimeController = TextEditingController(
        text: startTime != null
            ? DateFormat.Hm()
                .format(DateTime(2022, 1, 1, startTime.hour, startTime.minute))
            : '');
    TextEditingController endTimeController = TextEditingController(
        text: endTime != null
            ? DateFormat.Hm()
                .format(DateTime(2022, 1, 1, endTime.hour, endTime.minute))
            : '');
    // TextEditingController quantityController =
    //     TextEditingController(text: quantity.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.post_add),
                SizedBox(width: 2),
                Text('Dettagli'),
              ],
            ),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: startTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        initialStartTime = picked;
                        startTime = picked;
                        startTimeController.text = DateFormat.Hm().format(
                            DateTime(2022, 1, 1, picked.hour, picked.minute));
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Inizio',
                        labelStyle: const TextStyle(fontSize: 16.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 243, 159, 33),
                              width: 2.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: startTimeController,
                              enabled: false,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () async {
                              TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: startTime ?? TimeOfDay.now(),
                              );
                              if (picked != null) {
                                initialStartTime = picked;
                                startTime = picked;
                                startTimeController.text = DateFormat.Hm()
                                    .format(DateTime(2022, 1, 1, picked.hour,
                                        picked.minute));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: endTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        initialEndTime = picked;
                        endTime = picked;
                        endTimeController.text = DateFormat.Hm().format(
                            DateTime(2022, 1, 1, picked.hour, picked.minute));
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Fine',
                        labelStyle: const TextStyle(fontSize: 16.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 243, 159, 33),
                              width: 2.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: endTimeController,
                              enabled: false,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () async {
                              TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: endTime ?? TimeOfDay.now(),
                              );
                              if (picked != null) {
                                initialEndTime = picked;
                                endTime = picked;
                                endTimeController.text = DateFormat.Hm().format(
                                    DateTime(2022, 1, 1, picked.hour,
                                        picked.minute));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                      child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      side: WidgetStateProperty.all<BorderSide>(
                        const BorderSide(color: Colors.grey),
                      ),
                      minimumSize: WidgetStateProperty.all<Size>(
                          const Size(double.infinity, 40)),
                    ),
                    child: const Text(
                      'Annulla',
                      style: TextStyle(color: Colors.black),
                    ),
                  )),
                  const SizedBox(width: 8),
                  Expanded(
                      child: ElevatedButton(
                    onPressed: () async {
                      if (startTime != null && endTime != null) {
                        String duration =
                            calculateDuration(startTime!, endTime!);

                        double parseDuration(String durationString) {
                          if (durationString.contains(':')) {
                            final parts = durationString.split(':');
                            final hours = double.parse(parts[0]);
                            final minutes = double.parse(parts[1]);
                            return hours + (minutes / 60);
                          } else {
                            return double.parse(durationString);
                          }
                        }

                        String formatHour(int hour) {
                          return hour < 10 ? '0$hour' : '$hour';
                        }

                        String formatMinute(int minute) {
                          return minute < 10 ? '0$minute' : '$minute';
                        }

                        String formattedStartTime =
                            '${formatHour(startTime!.hour)}:${formatMinute(startTime!.minute)}';
                        String formattedEndTime =
                            '${formatHour(endTime!.hour)}:${formatMinute(endTime!.minute)}';

                        String dateTimeStringIni =
                            '${DateFormat('yyyy-MM-dd').format(DateTime.now())} $formattedStartTime';
                        String dateTimeStringFin =
                            '${DateFormat('yyyy-MM-dd').format(DateTime.now())} $formattedEndTime';

                        DateTime dtOraIni = DateTime.parse(dateTimeStringIni);
                        DateTime dtOraFin = DateTime.parse(dateTimeStringFin);

                        var ultimaModifica = DateTime.now();

                        final operatore =
                            await secureStorage.read(key: 'username') ?? '';
                        var interventiDbProvider =
                            ref.read(interventoApertoStateProvider.notifier);
                        await interventiDbProvider.updateInterventoModifica(
                            operatoreModifica: operatore,
                            ultimaModifica: ultimaModifica,
                            status: 'MOD');

                        double durationDouble = parseDuration(duration);

                        Map<String, dynamic> params = {
                          'dataInserimento':
                              DateFormat('yyyy-MM-dd').format(DateTime.now()),
                          'quantita': durationDouble,
                          'durataIni': dtOraIni,
                          'durataFin': dtOraFin,
                          'note': notes,
                          'operatore': operatore,
                        };

                        Map<String, dynamic> resultMapDocId = {};

                        await addRiga(articolo, ref, params, resultMapDocId);

                        initialStartTime = startTime;
                        initialEndTime = endTime;
                      }

                      final result = ref
                          .read(movimentoMagazzinoApiRepositoryProvider)
                          .updateQuantity(
                            codArt: articolo.codice,
                            desMov: articolo.descrizione,
                            note: notes,
                            tipoMov: 40,
                            mag: articolo.magazzino.codice ?? '',
                            umMov: articolo.unimis.codice ?? '',
                            qtaMov: quantity.toDouble(),
                          );

                      if (result != null) {
                        Navigator.pop(context);
                        return;
                      }

                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      side: WidgetStateProperty.all<BorderSide>(
                        const BorderSide(color: Colors.grey), // Bordo grigio
                      ),
                      minimumSize: WidgetStateProperty.all<Size>(const Size(
                          double.infinity,
                          40)), // Larghezza espansa e altezza 50
                    ),
                    child: const Text(
                      'Conferma',
                      style: TextStyle(color: Colors.black),
                    ),
                  )),
                ],
              ),
            ]);
      },
    );
  }

  final sendEmailProvider = StateProvider<bool>((ref) => false);

  void _showQuantitaDialog(
    BuildContext context,
    Articolo articolo,
    Intervento intervento,
    WidgetRef ref,
  ) async {
    double quantity = 1;
    String notes = '';
    TextEditingController quantityController =
        TextEditingController(text: quantity.toString());
    TextEditingController notesController = TextEditingController();
    const secureStorage = FlutterSecureStorage();

    final disponibilitaRepository =
        ref.read(disponibilitaArticoliApiRepositoryProvider);
    final dataLim = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String codArt = articolo.codice;

    var sendEmailState = ref.watch(sendEmailProvider);

    double disp = 0;
    double giac = 0;
    double scorta = articolo.mtsScSic;

    final qtaResiduaResponse =
        await disponibilitaRepository.getDisponibilitaArticoli(dataLim, codArt);

    if (qtaResiduaResponse != null) {
      final magazzinoSede = qtaResiduaResponse.firstWhere(
        (element) => element['magazzino'] == 'SEDE',
        orElse: () => null,
      );
      if (magazzinoSede != null) {
        disp = magazzinoSede['disp'];
        giac = magazzinoSede['giac'];
        //scorta = magazzinoSede['scoSic'];
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 2),
                  Text('${articolo.codice} (${articolo.unimis.codice})'),
                ],
              ),
              const Divider(),
              Text(
                articolo.descrizione,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      iconSize: 20,
                      onPressed: () {
                        if (quantity > 1) {
                          quantity--;
                          quantityController.text = quantity.toString();
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          String sanitizedValue = value.replaceAll(',', '.');

                          quantity = double.tryParse(sanitizedValue) ?? 1;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Quantità',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.add),
                      iconSize: 20,
                      onPressed: () {
                        quantity++;
                        quantityController.text = quantity.toString();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DataTable(
                      columns: const [
                        DataColumn(label: Text('Disp.')),
                        DataColumn(label: Text('Scorta')),
                        DataColumn(label: Text('Giac.')),
                      ],
                      rows: [
                        DataRow(cells: [
                          DataCell(Text(disp.toInt().toString())),
                          DataCell(Text(scorta.toInt().toString())),
                          DataCell(Text(giac.toInt().toString())),
                        ]),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(height: 20),
                        RoundCheckBox(
                          onTap: (selected) {
                            sendEmailState = !sendEmailState;
                          },
                          size: 25,
                          isChecked: sendEmailState,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text('Invia segnalazione'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: notesController,
                  onChanged: (value) {
                    notes = value;
                  },
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                  ),
                  maxLength: 250,
                  buildCounter: (BuildContext context,
                      {required int currentLength,
                      required bool isFocused,
                      required int? maxLength}) {
                    return Text('$currentLength/$maxLength');
                  },
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      side: WidgetStateProperty.all<BorderSide>(
                        const BorderSide(color: Colors.grey),
                      ),
                      minimumSize: WidgetStateProperty.all<Size>(
                          const Size(double.infinity, 40)),
                    ),
                    child: const Text(
                      'Annulla',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      var operatore =
                          await secureStorage.read(key: 'username') ?? '';

                      var ultimaModifica = DateTime.now();
                      var interventiDbProvider =
                          ref.read(interventoApertoStateProvider.notifier);
                      await interventiDbProvider.updateInterventoModifica(
                          operatoreModifica: operatore,
                          ultimaModifica: ultimaModifica,
                          status: 'MOD');

                      double quantityDouble = double.parse(quantity.toString());
                      Map<String, dynamic> params = {
                        'operatore': operatore,
                        'dataInserimento':
                            DateFormat('yyyy-MM-dd').format(DateTime.now()),
                        'quantita': quantityDouble,
                        'note': notes,
                      };

                      Map<String, dynamic> resultMapDocId = {
                        //'docId': docId,
                      };

                      await addRigaQuantita(articolo, ref, params, resultMapDocId);

                      if (sendEmailState) {
                        await _sendEmail(context, ref, articolo);
                      }

                      final result = ref
                          .read(movimentoMagazzinoApiRepositoryProvider)
                          .updateQuantity(
                            codArt: articolo.codice,
                            desMov: articolo.descrizione,
                            note: notes,
                            tipoMov: 40,
                            mag: articolo.magazzino.codice ?? '',
                            umMov: articolo.unimis.codice ?? '',
                            qtaMov: quantity.toDouble(),
                          );

                      if (result != null) {
                        Navigator.pop(context);

                        return;
                      } else {}
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      side: WidgetStateProperty.all<BorderSide>(
                        const BorderSide(color: Colors.grey),
                      ),
                      minimumSize: WidgetStateProperty.all<Size>(
                          const Size(double.infinity, 40)),
                    ),
                    child: const Text(
                      'Conferma',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendEmail(
      BuildContext context, WidgetRef ref, Articolo articolo) async {
    final smtpServer = SmtpServer(
      'smtp-mail.outlook.com',
      username: 'tecnico@salvadorsrl.it',
      password: 'Sergio@07062024',
      port: 587,
      ssl: false,
      allowInsecure: false,
    );

    final message = Message()
      ..from =
          const prefix.Address('tecnico@salvadorsrl.it', 'Tecnico Salvador')
      ..recipients.add('tecnico@salvadorsrl.it')
      ..ccRecipients.add('assistenza@icoldo.it')
      ..subject =
          'Segnalazione Articolo ${articolo.codice} - ${articolo.descrizione}'
      ..text =
          'Questa è una mail inviata dal sistema per una segnalazione all\'articolo: ${articolo.codice} - ${articolo.descrizione} ';

    try {
      final sendReport = await send(message, smtpServer);

      // Mostra un messaggio di successo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Email inviata con successo a: ${'tecnico@salvadorsrl.it'}'),
          backgroundColor: Colors.green,
        ),
      );

      print('Message sent: ${sendReport.messageSendingEnd}');
      print('Preview URL: ${sendReport.mail}');
    } catch (e) {
      // Mostra un messaggio di errore
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore durante l\'invio della email: $e'),
          backgroundColor: Colors.red,
        ),
      );

      print('Error occurred: $e');
    }
  }

  void modifyDettagliDialog(
      BuildContext context,
      Articolo? articolo,
      Intervento intervento,
      WidgetRef ref,
      Riga riga,
      double? nuovaQuantita,
      double quantity,
      String notes) async {
    TextEditingController quantityController =
        TextEditingController(text: quantity.toString());
    TextEditingController notesController =
        TextEditingController(text: riga.note);

    const secureStorage = FlutterSecureStorage();

    final double initialQuantity = quantity;

    TextEditingController quantityControllerNew =
        TextEditingController(text: initialQuantity.toString());

    final disponibilitaRepository =
        ref.read(disponibilitaArticoliApiRepositoryProvider);
    final dataLim = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String? codArt = intervento.righe
        .firstWhere(
          (element) => element.riga == riga.riga,
        )
        .articolo
        ?.codice;
    String? artUnimis = intervento.righe
        .firstWhereOrNull((element) => element.riga == riga.riga)
        ?.articolo
        ?.umPrincipale;
    String? descrArt = intervento.righe
        .firstWhere(
          (element) => element.riga == riga.riga,
        )
        .articolo
        ?.descrizione;
    if (codArt == null) {
      return;
    }

    double disp = 0;
    double giac = 0;
    double scorta = 0;
    // ignore: unused_local_variable
    String? unimis;

    final qtaResiduaResponse =
        await disponibilitaRepository.getDisponibilitaArticoli(dataLim, codArt);

    if (qtaResiduaResponse != null) {
      final magazzinoSede = qtaResiduaResponse.firstWhere(
          (element) => element['magazzino'] == 'SEDE',
          orElse: () => null);
      if (magazzinoSede != null) {
        disp = magazzinoSede['disp'];
        giac = magazzinoSede['giac'];
        scorta = magazzinoSede['scoSic'];
        unimis = magazzinoSede['unimis'];
      }
    }

    double difference = disp - quantity;
    TextEditingController differenceController =
        TextEditingController(text: difference.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 2),
                  Text('$codArt ${artUnimis != null ? '($artUnimis)' : ''}'),
                ],
              ),
              const Divider(),
              Text(
                '$descrArt',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      iconSize: 20,
                      onPressed: () {
                        if (quantity > 1) {
                          quantity--;
                          quantityController.text = quantity.toString();
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          // Sostituisce la virgola con il punto se presente
                          String sanitizedValue = value.replaceAll(',', '.');

                          // Converte il valore in double
                          quantity = double.tryParse(sanitizedValue) ?? 1;
                          difference = disp - quantity;
                          differenceController.text = difference.toString();
                        },
                        decoration: const InputDecoration(
                          labelText: 'Quantità',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.add),
                      iconSize: 20,
                      onPressed: () {
                        quantity++;
                        quantityController.text = quantity.toString();
                        difference = disp - quantity;
                        differenceController.text =
                            difference.toInt().toString();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Disp.')),
                    DataColumn(label: Text('Scorta')),
                    DataColumn(label: Text('Giac.')),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text(disp.toInt().toString())),
                      DataCell(Text(scorta.toInt().toString())),
                      DataCell(Text(giac.toInt().toString())),
                    ]),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                    controller: notesController,
                    onChanged: (value) {
                      notes = value;
                    },
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                    ),
                    maxLength: 250,
                    buildCounter: (BuildContext context,
                        {required int currentLength,
                        required bool isFocused,
                        required int? maxLength}) {
                      return Text('$currentLength/$maxLength');
                    }),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                var ultimaModifica = DateTime.now();
                final operatore =
                    await secureStorage.read(key: 'username') ?? '';
                var interventiDbProvider =
                    ref.read(interventoApertoStateProvider.notifier);
                await interventiDbProvider.updateInterventoModifica(
                    operatoreModifica: operatore,
                    ultimaModifica: ultimaModifica);

                //double quantityDouble = double.parse(quantity.toString());
                riga.qta = quantity;
                riga.note = notes;

                Navigator.pop(context);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => RegistrazioneInterventoPage()));

                await ref
                    .read(interventoApertoStateProvider.notifier)
                    .updateRigaQuantita(riga, quantity);

                final int quantityValue =
                    int.tryParse(quantityControllerNew.text) ?? 0;
                final int tipoMov = riga.qta! > quantityValue ? 40 : 41;

                int quantityDifferenceReso = 0;
                if (tipoMov == 41) {
                  quantityDifferenceReso = quantityValue - quantity.toInt();
                }

                int quantityDifferencePrelievo = 0;
                if (tipoMov == 40) {
                  quantityDifferencePrelievo = quantity.toInt() - quantityValue;
                }

                final double qtaMov = tipoMov == 40
                    ? quantityDifferencePrelievo.toDouble()
                    : quantityDifferenceReso.toDouble();

                final result = ref
                    .read(movimentoMagazzinoApiRepositoryProvider)
                    .updateQuantity(
                        codArt: articolo!.codice,
                        desMov: articolo.descrizione,
                        note: notes,
                        tipoMov: tipoMov,
                        mag: articolo.magazzino.descrizione ?? '',
                        umMov: articolo.unimis.codice ?? '',
                        qtaMov: qtaMov);

                if (result != null) {
                  Navigator.pop(context);

                  return;
                } else {}

                Navigator.pop(context);
              },
              child: const Text('Conferma'),
            ),
          ],
        );
      },
    );
  }

  TimeOfDay? lastStartTime;
  TimeOfDay? lastEndTime;

  void modifyDurataDialog(BuildContext context, Riga riga,
      double? nuovaQuantita, WidgetRef ref) async {
    // double quantity = riga.qta ?? 1;
    String notes = riga.note ?? '';

    DateTime initialDateTime =
        DateTime(2022, 1, 1, riga.dtOraIni!.hour, riga.dtOraIni!.minute);
    DateTime endDateTime =
        DateTime(2022, 1, 1, riga.dtOraFin!.hour, riga.dtOraFin!.minute);

    TimeOfDay initialStartTimeOfDay =
        TimeOfDay(hour: initialDateTime.hour, minute: initialDateTime.minute);
    TimeOfDay initialEndTimeOfDay =
        TimeOfDay(hour: endDateTime.hour, minute: endDateTime.minute);

    TimeOfDay? savedStartTime = lastStartTime ?? initialStartTimeOfDay;
    TimeOfDay? savedEndTime = lastEndTime ?? initialEndTimeOfDay;

    const secureStorage = FlutterSecureStorage();

    // TextEditingController notesController = TextEditingController(text: notes);
    TextEditingController startTimeController = TextEditingController(
        text: savedStartTime != null
            ? DateFormat.Hm().format(DateTime(
                2022, 1, 1, savedStartTime.hour, savedStartTime.minute))
            : '');
    TextEditingController endTimeController = TextEditingController(
        text: savedEndTime != null
            ? DateFormat.Hm().format(
                DateTime(2022, 1, 1, savedEndTime.hour, savedEndTime.minute))
            : '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit),
                SizedBox(width: 2),
                Text('Modifica Durata'),
              ],
            ),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: savedStartTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        lastStartTime = picked;
                        savedStartTime = picked;
                        startTimeController.text = DateFormat.Hm().format(
                            DateTime(2022, 1, 1, picked.hour, picked.minute));
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Orario di Inizio',
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: startTimeController,
                              enabled: false,
                              decoration: const InputDecoration(
                                hintText: 'Seleziona orario',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () async {
                              TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: savedStartTime ?? TimeOfDay.now(),
                              );
                              if (picked != null) {
                                lastStartTime = picked;
                                savedStartTime = picked;
                                startTimeController.text = DateFormat.Hm()
                                    .format(DateTime(2022, 1, 1, picked.hour,
                                        picked.minute));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: savedEndTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        lastEndTime = picked;
                        savedEndTime = picked;
                        endTimeController.text = DateFormat.Hm().format(
                            DateTime(2022, 1, 1, picked.hour, picked.minute));
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Orario di Fine',
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: endTimeController,
                              enabled: false,
                              decoration: const InputDecoration(
                                hintText: 'Seleziona orario',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () async {
                              TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: savedEndTime ?? TimeOfDay.now(),
                              );
                              if (picked != null) {
                                lastEndTime = picked;
                                savedEndTime = picked;
                                endTimeController.text = DateFormat.Hm().format(
                                    DateTime(2022, 1, 1, picked.hour,
                                        picked.minute));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          textStyle: const TextStyle(color: Colors.black)),
                      child: const Text('Annulla',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        TimeOfDay finalStartTime =
                            lastStartTime ?? savedStartTime!;
                        TimeOfDay finalEndTime = lastEndTime ?? savedEndTime!;

                        DateTime startDateTime = DateTime(2022, 1, 1,
                            finalStartTime.hour, finalStartTime.minute);
                        DateTime endDateTime = DateTime(
                            2022, 1, 1, finalEndTime.hour, finalEndTime.minute);

                        String duration =
                            calculateDuration(finalStartTime, finalEndTime);

                        var ultimaModifica = DateTime.now();
                        final operatore =
                            await secureStorage.read(key: 'username') ?? '';
                        var interventiDbProvider =
                            ref.read(interventoApertoStateProvider.notifier);
                        await interventiDbProvider.updateInterventoModifica(
                            operatoreModifica: operatore,
                            ultimaModifica: ultimaModifica);

                        double parseDuration(String durationString) {
                          if (durationString.contains(':')) {
                            final parts = durationString.split(':');
                            final hours = double.parse(parts[0]);
                            final minutes = double.parse(parts[1]);
                            return hours + (minutes / 60);
                          } else {
                            return double.parse(durationString);
                          }
                        }

                        double durationDouble = parseDuration(duration);

                        nuovaQuantita = durationDouble;
                        riga.qta = nuovaQuantita;
                        riga.note = notes;
                        riga.dtOraIni = startDateTime;

                        riga.dtOraFin = endDateTime;

                        Navigator.pop(context);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => RegistrazioneInterventoPage()));

                        // Update state
                        await ref
                            .read(interventoApertoStateProvider.notifier)
                            .updateRigaQuantita(riga, nuovaQuantita);
                      },
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          textStyle: const TextStyle(color: Colors.black)),
                      child: const Text('Conferma',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              ),
            ]);
      },
    );
  }

  void _showAggiungiNotaDialog(
      BuildContext context, WidgetRef ref, Riga? riga) async {
    String notaText = '';
    final TextEditingController controller =
        TextEditingController(text: riga?.note);

    const secureStorage = FlutterSecureStorage();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.note_add),
              SizedBox(width: 2),
              Text('Nota'),
            ],
          ),
          content: SizedBox(
            width: 300,
            child: TextField(
              controller: controller,
              maxLines: 5,
              maxLength: 250,
              decoration: const InputDecoration(
                hintText: 'Inserisci una nota',
                contentPadding: EdgeInsets.all(16.0),
              ),
              buildCounter: (BuildContext context,
                  {required int currentLength,
                  required bool isFocused,
                  required int? maxLength}) {
                return Text('$currentLength/$maxLength');
              },
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      side: WidgetStateProperty.all<BorderSide>(
                        const BorderSide(color: Colors.grey),
                      ),
                      minimumSize: WidgetStateProperty.all<Size>(
                          const Size(double.infinity, 40)),
                    ),
                    child: const Text('Annulla',
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // if (controller.text.isNotEmpty) {
                      //   notaText = controller.text;
                      //   _stampaNellaPage('$notaText', ref);
                      //   Navigator.pop(context);
                      // }

                      var ultimaModifica = DateTime.now();
                      final operatore =
                          await secureStorage.read(key: 'username') ?? '';
                      var interventiDbProvider =
                          ref.read(interventoApertoStateProvider.notifier);
                      await interventiDbProvider.updateInterventoModifica(
                          operatoreModifica: operatore,
                          ultimaModifica: ultimaModifica);

                      notaText = controller.text;

                      Map<String, dynamic> params = {
                        'operatore': operatore,
                        'dataInserimento':
                            DateFormat('yyyy-MM-dd').format(DateTime.now()),
                        'quantita': 0,
                        //'durata': duration,
                        'note': notaText,
                      };

                      await addNota(ref, params);
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => RegistrazioneInterventoPage()));
                    },
                    style: ButtonStyle(
                      side: WidgetStateProperty.all<BorderSide>(
                        const BorderSide(color: Colors.grey),
                      ),
                      minimumSize: WidgetStateProperty.all<Size>(
                          const Size(double.infinity, 40)),
                    ),
                    child: const Text('Salva',
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showModifyNotaDialog(
      BuildContext context, WidgetRef ref, Riga riga, String? nuovaNota) async {
    // String notaText = '';
    final TextEditingController controller =
        TextEditingController(text: riga.note);

    const secureStorage = FlutterSecureStorage();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.note_add),
              SizedBox(width: 2),
              Text('Nota'),
            ],
          ),
          content: SizedBox(
            width: 300,
            child: TextField(
              controller: controller,
              maxLines: 5,
              maxLength: 250,
              decoration: const InputDecoration(
                hintText: 'Inserisci una nota',
                contentPadding: EdgeInsets.all(16.0),
              ),
              buildCounter: (BuildContext context,
                  {required int currentLength,
                  required bool isFocused,
                  required int? maxLength}) {
                return Text('$currentLength/$maxLength');
              },
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      side: WidgetStateProperty.all<BorderSide>(
                        const BorderSide(color: Colors.grey),
                      ),
                      minimumSize: WidgetStateProperty.all<Size>(
                          const Size(double.infinity, 40)),
                    ),
                    child: const Text('Annulla',
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // if (controller.text.isNotEmpty) {
                      //   notaText = controller.text;
                      //   _stampaNellaPage('$notaText', ref);
                      //   Navigator.pop(context);
                      // }

                      var ultimaModifica = DateTime.now();
                      final operatore =
                          await secureStorage.read(key: 'username') ?? '';
                      var interventiDbProvider =
                          ref.read(interventoApertoStateProvider.notifier);
                      await interventiDbProvider.updateInterventoModifica(
                          operatoreModifica: operatore,
                          ultimaModifica: ultimaModifica,
                          status: 'MOD');
                      nuovaNota = controller.text;

                      riga.note = nuovaNota;
                      riga.descrizione = nuovaNota;

                      Navigator.pop(context);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => RegistrazioneInterventoPage()));

                      await updateNota(riga, nuovaNota, ref);
                    },
                    style: ButtonStyle(
                      side: WidgetStateProperty.all<BorderSide>(
                        const BorderSide(color: Colors.grey),
                      ),
                      minimumSize: WidgetStateProperty.all<Size>(
                          const Size(double.infinity, 40)),
                    ),
                    child: const Text('Salva',
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class AllegatiManager {
  static List<PlatformFile> allegatiTemporanei = [];

  int numeroAllegati = AllegatiManager.allegatiTemporanei.length;
}

class PdfPreviewPage extends StatelessWidget {
  final String base64File;
  final String fileName;

  const PdfPreviewPage({
    super.key,
    required this.base64File,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    String fileExtension = _getFileExtension(fileName);
    return Scaffold(
      appBar: AppBar(
        title: Text('ANTEPRIMA ALLEGATO: $fileName'),
        backgroundColor: const Color.fromARGB(255, 236, 201, 148),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              await _downloadFile(context);
            },
          ),
        ],
      ),
      body: _buildPreview(fileExtension),
    );
  }

  String _getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  Widget _buildPreview(String fileExtension) {
    switch (fileExtension) {
      case 'pdf':
        return PDFView(
          pdfData: base64Decode(base64File),
        );
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'tiff':
        return Image.memory(base64Decode(base64File));
      case 'docx':
        return const Center(
            child: Text('Anteprima DOCX non ancora supportata.'));
      case 'xlsx':
        return const Center(
            child: Text('Anteprima XLSX non ancora supportata.'));
      default:
        return const Center(child: Text('Tipo di file non supportato.'));
    }
  }

  Future<void> _downloadFile(BuildContext context) async {
    if (await Permission.storage.request().isGranted) {
      try {
        final decodedBytes = base64Decode(base64File);

        Directory? directory;
        if (Platform.isAndroid || Platform.isIOS) {
          directory = await getExternalStorageDirectory();
          if (directory != null) {
            directory = Directory('${directory.path}/Download');
            if (!directory.existsSync()) {
              directory.createSync();
            }
          }
        } else {
          directory = Directory('C:/Users/Barbara/Downloads');
          if (!directory.existsSync()) {
            directory.createSync();
          }
        }

        if (directory != null) {
          final filePath = '${directory.path}/$fileName';
          final file = File(filePath);

          await file.writeAsBytes(decodedBytes);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File salvato in: $filePath'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante il download: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permesso negato per accedere alla memoria.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class ImageViewScreen extends StatelessWidget {
  final String filePath;

  const ImageViewScreen({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    final String fileExtension = filePath.split('.').last.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizza File'),
      ),
      body: Center(
        child: fileExtension == 'pdf'
            ? PDFView(
                filePath: filePath,
              )
            : Image.file(File(filePath)),
      ),
    );
  }
}

class RotatingHourglass extends StatefulWidget {
  const RotatingHourglass({super.key});

  @override
  RotatingHourglassState createState() => RotatingHourglassState();
}

class RotatingHourglassState extends State<RotatingHourglass>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animationController,
      child: const Icon(
        Icons.hourglass_bottom,
        size: 40,
      ),
    );
  }
}
