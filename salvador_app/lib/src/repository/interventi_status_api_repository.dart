import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:salvador_task_management/src/config/providers.dart';
import 'package:salvador_task_management/src/models/intervento_status_model.dart';

part 'interventi_status_api_repository.g.dart';

final interventiStatusApiRepositoryProvider = Provider((ref) {
  final dio = ref.read(dioProvider);
  final config = ref.read(configProvider);
  return InterventiStatusApiRepository(dio: dio, config: config);
});

@Riverpod()
Future<List<InterventoStatus>> interventiStatusApi(
    InterventiStatusApiRef ref, String datalimite) async {
  var interventiRepository = ref.read(interventiStatusApiRepositoryProvider);
  var interventiCollection =
      await interventiRepository.getInterventi(datalimite);

  return interventiCollection;
}

class InterventiStatusApiRepository {
  final Dio dio;
  final GlobalConfiguration config;

  InterventiStatusApiRepository({required this.dio, required this.config}) {
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

  Future<List<InterventoStatus>> getInterventi(String datalimite) async {
    final salvadorApiUrl = config.getValue("SalvadorApiUrl");

    final Map<String, dynamic> requestData = {
      'utente': 'ADMIN',
      'dataLimite': datalimite,
    };

    try {
      final response = await dio.post(
        '$salvadorApiUrl/commerciale/external/storicoOrdiniStatusSalvador',
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
        data: requestData,
      );

      final List<dynamic> rawData = response.data;
      List<InterventoStatus> interventiStatusList =
          rawData.map((data) => InterventoStatus.fromJson(data)).toList();

      return interventiStatusList;
    } catch (e) {
      print('Error during API call: $e');
      throw Exception('Failed to fetch Interventi Aperti');
    }
  }
}
