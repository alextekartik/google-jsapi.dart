/// The legacy `gapi.auth` (OAuth 2 implicit flow of the JS client):
/// [loadGapiAuth], [GapiAuth.authorize].
///
/// Deprecated by Google and closed to new client ids: new code signs in
/// with Google Identity Services (`accounts.google.com/gsi/client`).
@Deprecated('gapi.auth is deprecated by Google, use Google Identity Services')
library;

export 'src/gapi_impl.dart' show GapiAuth, loadGapiAuth;
