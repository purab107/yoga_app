/// API Configuration for Yoga App
/// Update baseUrl to switch between local and production environments
class ApiConfig {
  // 💻 Local Development URL (Active) - Update this if your PC's IP changes
  static const String baseUrl = 'http://10.210.61.25:8000';
  
  // 🌐 Production URL (Azure) - Uncomment to use Azure backend
  // static const String baseUrl = 'https://yoga-app-rg-dchbg5dtg8aah2fw.centralindia-01.azurewebsites.net';
  
  // API Endpoints
  static const String analyzeEndpoint = '$baseUrl/analyze-pose';
  static const String healthEndpoint = '$baseUrl/';
}
