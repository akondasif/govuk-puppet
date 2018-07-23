# == Class: govuk_pgbouncer
#
# Installs and configures pgbouncer to connect to our Postgres servers.
#
# === Parameters
#
# [*databases*]
#   A list of databases for pgbouncer to connect to
#
class govuk_pgbouncer(
  $databases = [],
) {

  class { '::pgbouncer':
    user      => 'postgres',
    group     => 'postgres',
    databases => $databases,
    userlist  => [{user => 'foo', password => 'bar'}]
  }
}
