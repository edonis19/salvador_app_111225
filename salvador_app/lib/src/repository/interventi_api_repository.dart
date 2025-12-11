import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:salvador_task_management/src/config/providers.dart';
import 'package:salvador_task_management/src/models/intervento_model.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

part 'interventi_api_repository.g.dart';

final interventiApiRepositoryProvider = Provider((ref) {
  final dio = ref.read(dioProvider);
  final config = ref.read(configProvider);
  return InterventiApiRepository(dio: dio, config: config);
});

@Riverpod()
Future<List<Intervento>> interventiApi(
    InterventiApiRef ref, String datalimite) async {
  var interventiRepository = ref.read(interventiApiRepositoryProvider);
  var interventiCollection =
      await interventiRepository.getInterventi(datalimite);
  return interventiCollection;
}

class InterventiApiRepository {
  final Dio dio;
  final GlobalConfiguration config;

  InterventiApiRepository({required this.dio, required this.config}) {
    dio.interceptors.add(LogInterceptor());
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final HttpClient client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;

        return client;
      },
    );
  }

  Future<List<Intervento>> getInterventi(String datalimite) async {
    //DateTime now = DateTime.now();
    //int currentMonth = now.month;
    //int currentYear = now.year;

    return await _fetchInterventi(datalimite);
  }

  Future<List<Intervento>> getInterventiPerMeseSelezionato(
      int year, int month) async {
    DateTime dataLimite = DateTime(year, month, 1);
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss.SSS");
    var formatteddatalimite = dateFormat.format(dataLimite);
    return await _fetchInterventi(formatteddatalimite);
  }

  Future<List<Intervento>> _fetchInterventi(String datalimite) async {
    final salvadorApiUrl = config.getValue("SalvadorApiUrl");

    // Calcola la dataLimite come il primo giorno del mese specificato
    //DateTime dataLimite = DateTime(year, month, 1);

    final Map<String, dynamic> requestData = {
      'utente': 'ADMIN',
      'dataLimite': datalimite,
    };

    try {
      final response = await dio.post(
        '$salvadorApiUrl/commerciale/external/ordiniTabletSalvador',
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
        data: requestData,
      );

      final List<dynamic> rawData = response.data;
      List<Intervento> interventiList =
          rawData.map((data) => Intervento.fromJson(data)).toList();

      // ✅ Filtro: rimuovi interventi chiusi
      interventiList =
          interventiList.where((i) => i.status.toUpperCase() != 'CHI').toList();

      return interventiList;
    } catch (e) {
      print('Error during API call: $e');
      throw Exception('Failed to fetch Interventi Aperti');
    }
  }
}
