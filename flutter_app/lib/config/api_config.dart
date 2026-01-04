/// API Configuration for Yoga App
/// Update baseUrl to switch between local and production environments
class ApiConfig {
  // 🌐 Production URL (Azure)
  static const String baseUrl = 'https://yoga-app-rg-dchbg5dtg8aah2fw.centralindia-01.azurewebsites.net';
  
  // 💻 Local Development URL (uncomment to use local backend)
  // static const String baseUrl = 'http://localhost:8000';
  // static const String baseUrl = 'http://192.168.1.9:8000'; // Your PC's IP for phone testing
  
  // API Endpoints
  static const String analyzeEndpoint = '$baseUrl/analyze-pose';
  static const String healthEndpoint = '$baseUrl/';
}
