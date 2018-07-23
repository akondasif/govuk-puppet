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
  # $databases = [],
) {

  $databases = [
    {
      source_db => 'publishing_api_development',
      dest_db   => 'publishing_api_development',
      host      => '127.0.0.1',
      auth_user => 'vagrant',
    }
  ]

  class { '::pgbouncer':
    user      => 'postgres',
    group     => 'postgres',
    databases => $databases,
    userlist  => false,
    config_params => {
      auth_type => 'hba',
      auth_hba_file => "/etc/postgresql/${::postgresql::globals::version}/main/pg_hba.conf"
    }
  }
}
