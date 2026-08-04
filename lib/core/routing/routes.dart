/// Routes nommées de l'application.
abstract final class Routes {
  static const login = '/login';
  static const signUp = '/signup';
  static const verifyPhone = '/verify-phone';
  static const dashboard = '/';
  static const establishmentOnboarding = '/establishments/onboarding';
  static const establishmentNew = '/establishments/new';
  static const invitationNew = '/establishments/invitations/new';
  static const invitations = '/invitations';
  static const team = '/equipe';
  static const clients = '/clients';
  static const clientNew = '/clients/new';
  static const clientDetail = '/clients/:id';
  static const clientEdit = '/clients/edit/:id';
  static const clientQr = '/clients/:id/qr';
  static const vehiculeDetail = '/vehicules/:id';
  static const services = '/services';
  static const serviceNew = '/services/new';
  static const serviceEdit = '/services/edit/:id';
  static const serviceCategoryNew = '/services/categories/new';
  static const serviceCategoryEdit = '/services/categories/edit/:id';
  static const produits = '/produits';
  static const produitNew = '/produits/new';
  static const produitEdit = '/produits/edit/:id';
  static const productCategoryNew = '/produits/categories/new';
  static const productCategoryEdit = '/produits/categories/edit/:id';
  static const inventories = '/inventaires';
  static const inventoryDetail = '/inventaires/:id';

  static String serviceEditPath(String id) => '/services/edit/$id';
  static String serviceCategoryEditPath(String id) =>
      '/services/categories/edit/$id';
  static String produitEditPath(String id) => '/produits/edit/$id';
  static String productCategoryEditPath(String id) =>
      '/produits/categories/edit/$id';
  static String inventoryDetailPath(String id) => '/inventaires/$id';
  static String clientDetailPath(String id) => '/clients/$id';
  static String clientEditPath(String id) => '/clients/edit/$id';
  static const prestationScan = '/prestations/scan';
  static const prestationNew = '/prestations/new';
  static const commandeNew = '/commandes/new';
  static const commandeDetail = '/commandes/:id';
  static const prestationDetail = '/prestations/:id';
  static const prestationJeton = '/prestations/:id/jeton';
  static const prestationFacture = '/prestations/:id/facture';
  static const jetonScan = '/jetons/scan';
  static const alertes = '/alertes';
  static const settings = '/settings';
  static const reports = '/rapports';
  static const more = '/plus';
  static const activityDetail = '/activity/:id';

  static String activityDetailPath(String id) => '/activity/$id';
  static String prestationDetailPath(String id) => '/prestations/$id';
  static String commandeDetailPath(String id) => '/commandes/$id';
}
