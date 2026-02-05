import 'api_service.dart';
import 'api_config.dart';

class ClientService {
  final ApiService _api = ApiService();

  // Get all clients
  Future<Map<String, dynamic>> getAllClients() async {
    return await _api.get(ApiConfig.clients);
  }

  // Get single client
  Future<Map<String, dynamic>> getClient(String clientId) async {
    return await _api.get(ApiConfig.client(clientId));
  }

  // Create client
  Future<Map<String, dynamic>> createClient(
    Map<String, dynamic> data,
  ) async {
    return await _api.post(
      ApiConfig.createClient,
      data,
    );
  }

  // Update client
  Future<Map<String, dynamic>> updateClient(
    String clientId,
    Map<String, dynamic> data,
  ) async {
    return await _api.put(
      ApiConfig.client(clientId),
      data,
    );
  }

  // Delete client
  Future<Map<String, dynamic>> deleteClient(String clientId) async {
    return await _api.delete(ApiConfig.client(clientId));
  }
}
