// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:reactive_dropdown_search/reactive_dropdown_search.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:salvador_task_management/src/features/pages/interventi_aperti/intervento_aperto_state.dart';
import 'package:salvador_task_management/src/features/pages/nuovo_intervento/clienti_controller.dart';
import 'package:salvador_task_management/src/features/pages/nuovo_intervento/clients_utils.dart';
import 'package:salvador_task_management/src/features/pages/nuovo_intervento/elencomatricole_controller.dart';
import 'package:salvador_task_management/src/features/pages/nuovo_intervento/nuovo_intervento_page_form.dart';
import 'package:salvador_task_management/src/features/pages/nuovo_intervento/nuovo_intervento_second_page.dart';
import 'package:salvador_task_management/src/features/pages/nuovo_intervento/nuovo_intervento_state.dart';
import 'package:salvador_task_management/src/models/elencomatricole_model.dart';
import 'package:salvador_task_management/src/models/intervento_model.dart';
import 'package:salvador_task_management/src/repository/interventi_db_repository.dart';

class NuovoInterventoPage extends ConsumerWidget {
  const NuovoInterventoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(nuovoInterventoFormStateProvider);
    final btnController = RoundedLoadingButtonController();
    const secureStorage = FlutterSecureStorage();

    return Scaffold(
      body: ReactiveForm(
        formGroup: form,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final interventiErp = await ref
                                .read(interventiDbOpRepositoryProvider.notifier)
                                .getInterventiErp();

                            var targa = form
                                .control('rifMatricolaCliente')
                                .value
                                .toString()
                                .toUpperCase();

                            final bool esisteInterventoConTarga =
                                interventiErp.any(
                              (intervento) =>
                                  intervento.rifMatricolaCliente == targa,
                            );

                            if (esisteInterventoConTarga) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Esiste un intervento aperto con la stessa targa!'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }

                              return;
                            }

                            final clientiData = await ref
                                .read(clientiControllerProvider.future);
                            final codCliValue = form.control('desCli').value;

                            // Verifica se è stato selezionato un cliente
                            if (codCliValue == null || codCliValue.isEmpty) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Selezionare una targa per continuare'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }

                              btnController.reset();
                              return;
                            }

                            final clientiFiltrati = clientiData
                                .where((cliente) =>
                                    cliente.descrizione == codCliValue)
                                .toList();

                            String codiciClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.codice);
                            String partitaIvaClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.partitaIva ?? '');
                            String codFiscaleClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.codFiscale ?? '');
                            String indirizzoClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.indirizzo ?? '');
                            String capClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.cap ?? '');
                            String localitaClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.localita ?? '');
                            String provinciaClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.provincia ?? '');
                            String nazioneClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.nazione ?? '');
                            String faxClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.fax ?? '');
                            String emailClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.email ?? '');
                            String telefono1ClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.telefono1 ?? '');
                            String telefono2ClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.telefono2 ?? '');
                            String codListinoClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.codListino ?? '');
                            String categoriaIvaClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.categoriaIva ?? '');
                            String aspettoBeniClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.aspettoBeni ?? '');
                            String gruppoVenditaClientiString =
                                joinClienteField(clientiFiltrati,
                                    (c) => c.gruppoVendita ?? '');
                            String notePalmareClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.notePalmare ?? '');
                            String portoClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.porto ?? '');
                            String modTrasportoClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.modTrasporto ?? '');
                            String modConsegnaClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.modConsegna ?? '');
                            String causTrasportoClientiString =
                                joinClienteField(clientiFiltrati,
                                    (c) => c.causTrasporto ?? '');
                            String vettoreClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.vettore ?? '');
                            String pagamentoClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.pagamento ?? '');
                            String abiClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.abi ?? '');
                            String cabClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.cab ?? '');
                            String contocorrenteClientiString =
                                joinClienteField(clientiFiltrati,
                                    (c) => c.contocorrente ?? '');
                            String ibanClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.iban ?? '');
                            String statusBloccoClientiString = joinClienteField(
                                clientiFiltrati, (c) => c.statusBlocco ?? '');
                            String datiContabiliClientiString =
                                joinClienteField(clientiFiltrati,
                                    (c) => c.datiContabili ?? '');
                            int idClientiFiltratiInt = int.tryParse(
                                    joinClienteField(clientiFiltrati,
                                        (c) => c.id.toString())) ??
                                0;

                            double? contMatricola =
                                form.control('contMatricola').value;

                            var ultimaModifica = DateTime.now();
                            final operatore =
                                await secureStorage.read(key: 'username') ?? '';

                            final nuovoIntervento = Intervento(
                              id: null,
                              idTestata:
                                  DateTime.now().microsecondsSinceEpoch * -1,
                              barcode: null,
                              numDoc: 'null',
                              dataDoc: DateTime.now(),
                              totaleDoc: null,
                              tipoDoc: const TipoDoc(
                                  id: 112274,
                                  codice: 'RIPCLI',
                                  descrizione: 'RICHIESTA SERVIZI'),
                              cliente: InterventoCliente(
                                id: idClientiFiltratiInt,
                                codice: form.control('codCli').value,
                                descrizione: form.control('desCli').value,
                                partitaIva: partitaIvaClientiString,
                                codFiscale: codFiscaleClientiString,
                                indirizzo: indirizzoClientiString,
                                cap: capClientiString,
                                localita: localitaClientiString,
                                provincia: provinciaClientiString,
                                nazione: nazioneClientiString,
                                fax: faxClientiString,
                                email: emailClientiString,
                                telefono1: telefono1ClientiString,
                                telefono2: telefono2ClientiString,
                                codListino: codListinoClientiString,
                                categoriaIva: categoriaIvaClientiString,
                                aspettoBeni: aspettoBeniClientiString,
                                gruppoVendita: gruppoVenditaClientiString,
                                notePalmare: notePalmareClientiString,
                                porto: portoClientiString,
                                modTrasporto: modTrasportoClientiString,
                                modConsegna: modConsegnaClientiString,
                                causTrasporto: causTrasportoClientiString,
                                vettore: vettoreClientiString,
                                pagamento: pagamentoClientiString,
                                abi: abiClientiString,
                                cab: cabClientiString,
                                contocorrente: contocorrenteClientiString,
                                iban: ibanClientiString,
                                statusBlocco: statusBloccoClientiString,
                                datiContabili: datiContabiliClientiString,
                              ),
                              status: 'NO SYNC',
                              magazzino: null,
                              metodoPagamento: null,
                              dataConsegna: null,
                              indirizzoSpedizione: null,
                              modalitaSpedizione: null,
                              totaleDocumento: null,
                              modTrasp: null,
                              modCons: null,
                              aspBeni: null,
                              causTrasp: null,
                              vettore: null,
                              totPesoLordo: null,
                              totPesoNetto: null,
                              totVolume: null,
                              numColli: null,
                              numPallet: null,
                              stPrezziDdt: null,
                              telefono1: null,
                              telefono2: null,
                              matricola: form.control('codice').value,
                              telaio: form.control('telaio').value,
                              rifMatricolaCliente:
                                  form.control('rifMatricolaCliente').value,
                              contMatricola: contMatricola,
                              note: form.control('nota').value,
                              righe: [],
                              isDirty: true,
                              operatoreModifica: operatore,
                              ultimaModifica: ultimaModifica,
                              docId: null,
                            );

                            ref
                                .read(nuovoInterventoStateProvider.notifier)
                                .setIntervento(nuovoIntervento);
                            //interventiDbProvider.addOrUpdate(nuovoIntervento);

                            if (context.mounted) {
                              _showDetailsPageNuovoIntervento(
                                  nuovoIntervento, context, ref);
                            }

                            btnController.success();
                          } catch (exception) {
                            btnController.error();
                          }
                          Future.delayed(const Duration(seconds: 1), () {
                            btnController.reset();
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.green, width: 2),
                          backgroundColor:
                              const Color.fromARGB(0, 255, 255, 255),
                          foregroundColor:
                              Colors.black, // Colore del testo/icon
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Continua',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    padding: const EdgeInsets.only(top: 20),
                    child: Consumer(builder: ((context, ref, child) {
                      var matricoleData =
                          ref.watch(elencoMatricoleControllerProvider);

                      return matricoleData.when(
                        data: (targaCollection) {
                          var targaItems = targaCollection
                              .map<ElencoMatricole>((targa) => ElencoMatricole(
                                    id: targa.id,
                                    rifMatricolaCliente:
                                        targa.rifMatricolaCliente ?? '',
                                    codCli: targa.codCli,
                                    desCli: targa.desCli,
                                    codice: targa.codice,
                                    telaio: targa.telaio,
                                    descrizione: targa.descrizione,
                                    dataInizio: targa.dataInizio,
                                    dataFine: targa.dataFine,
                                    codArt: targa.codArt,
                                    marca: targa.marca,
                                    modello: targa.modello,
                                    rifMatrPadre: targa.rifMatrPadre,
                                  ))
                              .toList()
                            ..removeWhere((item) =>
                                item.rifMatricolaCliente!.isEmpty ||
                                item.rifMatricolaCliente!.trim().isEmpty);

                          return ReactiveDropdownSearch<dynamic,
                              ElencoMatricole>(
                            formControlName: 'targa',
                            clearButtonProps:
                                const ClearButtonProps(isVisible: true),
                            compareFn: (item1, item2) => item1.id == item2.id,
                            filterFn: (item, filter) =>
                                '${item.rifMatricolaCliente ?? ''} - ${item.descrizione}'
                                    .toString()
                                    .toLowerCase()
                                    .contains(filter.toLowerCase()),
                            itemAsString: (item) =>
                                '${item.rifMatricolaCliente ?? ''} - ${item.descrizione}',
                            items: targaItems,
                            onBeforeChange: (prevItem, nextItem) {
                              form.control('rifMatricolaCliente').value =
                                  nextItem?.rifMatricolaCliente;
                              form.control('desCli').value = nextItem?.desCli;
                              form.control('telaio').value = nextItem?.telaio;
                              form.control('codice').value = nextItem?.codice;

                              return Future.value(true);
                            },
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                hintText: "SELEZIONA TARGA",
                                hintStyle: const TextStyle(color: Colors.black),
                                fillColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                              ),
                            ),
                            popupProps: PopupProps.menu(
                              showSelectedItems: true,
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: "Cerca...",
                                  prefixIcon: const Icon(Icons.search),
                                ),
                              ),
                            ),
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (err, stack) =>
                            Center(child: Text('Error: $err')),
                      );
                    }))),
                const SizedBox(height: 40),
                ReactiveTextField(
                  formControlName: 'desCli',
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Cliente",
                    hintStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 40),
                ReactiveTextField(
                  formControlName: 'telaio',
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Telaio",
                    hintStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 40),
                ReactiveTextField(
                  formControlName: 'codice',
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Matricola",
                    hintStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  readOnly: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailsPageNuovoIntervento(
      Intervento nuovoIntervento, BuildContext context, WidgetRef ref) {
    //String righeDescrizione = 'null';
    //String righeDaFareDescrizione = 'null';
    //String? righeStatusEvasione = intervento.righe.isNotEmpty ? intervento.righe[0].statusEvasione : '';
    ref
        .read(interventoApertoStateProvider.notifier)
        .setIntervento(nuovoIntervento);
    //String? operatore = 'admin';
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NuovoInterventoSecondPage(),
      ),
    );
  }
}
