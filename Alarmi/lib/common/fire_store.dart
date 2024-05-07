enum DB {
  site('site'),
  siteHome('site_home'),
  user('user'),
  subscription('subscription'),
  subscriptionHome('subscription_home'),
  condition('condition');

  const DB(this.name);
  final String name;
}