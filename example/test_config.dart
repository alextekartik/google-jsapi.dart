library;

class AppOptions {
  // The Client ID obtained from the Google Cloud Console.
  String? clientId;
  // The Client Secret obtained from the Google Cloud Console.
  String? clientSecret;

  AppOptions.fromMap(Map<String, dynamic> map) {
    clientId = (map['clientId'] ?? map['client_id'])?.toString();
    clientSecret = (map['clientSecret'] ?? map['client_secret'])?.toString();
  }

  @override
  String toString() =>
      {'clientId': clientId, 'clientSecret': clientSecret}.toString();
}
