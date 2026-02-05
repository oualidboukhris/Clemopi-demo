import 'api_service.dart';
import 'api_config.dart';

class DashboardService {
  final ApiService _api = ApiService();

  // Get dashboard data
  Future<Map<String, dynamic>> getDashboardData() async {
    return await _api.get(ApiConfig.dashboard);
  }

  // Get analytics data
  Future<Map<String, dynamic>> getAnalytics() async {
    final response = await getDashboardData();

    if (response['success']) {
      return {
        'success': true,
        'data': response['data']['analytics'] ?? {},
      };
    }

    return response;
  }

  // Get header data
  Future<Map<String, dynamic>> getHeaderData() async {
    final response = await getDashboardData();

    if (response['success']) {
      return {
        'success': true,
        'data': response['data']['header'] ?? {},
      };
    }

    return response;
  }
}
