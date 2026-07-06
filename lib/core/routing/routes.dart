/// Routes nommées de l'application.
abstract final class Routes {
  static const login = '/login';
  static const dashboard = '/';
  static const clients = '/clients';
  static const clientNew = '/clients/new';
  static const clientDetail = '/clients/:id';
  static const clientQr = '/clients/:id/qr';
  static const vehiculeDetail = '/vehicules/:id';
  static const catalogue = '/catalogue';
  static const prestationScan = '/prestations/scan';
  static const prestationDetail = '/prestations/:id';
  static const prestationJeton = '/prestations/:id/jeton';
  static const prestationFacture = '/prestations/:id/facture';
  static const jetonScan = '/jetons/scan';
  static const alertes = '/alertes';
  static const settings = '/settings';
}
