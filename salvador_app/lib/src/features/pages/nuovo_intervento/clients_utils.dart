// cliente_utils.dart

import '../../../models/cliente_model.dart'; // <-- Importa qui il modello Cliente corretto

// Funzione generica per unire i campi
String joinClienteField(
  List<Cliente> clienti, 
  String Function(Cliente) selector
) => clienti.map(selector).join(',');

// Funzione generica per mappare i campi (come List)
List<T> mapClienteField<T>(List<Cliente> clienti, T Function(Cliente) selector) =>
    clienti.map(selector).toList();
