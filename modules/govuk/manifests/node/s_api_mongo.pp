# == Class: govuk::node::s_api_mongo
#
# api-mongo node
#
class govuk::node::s_api_mongo inherits govuk::node::s_base {
  include mongodb::server
  include govuk_env_sync

  collectd::plugin::tcpconn { 'mongo':
    incoming => 27017,
    outgoing => 27017,
  }

  limits::limits { 'api_mongo_nofile':
    ensure     => present,
    user       => 'mongodb',
    limit_type => 'nofile',
    both       => 4096,
  }

  if ! $::aws_migration {
    Govuk_mount['/var/lib/mongodb'] -> Class['mongodb::server']
    Govuk_mount['/var/lib/automongodbbackup'] -> Class['mongodb::backup']
    Govuk_mount['/var/lib/s3backup'] -> Class['mongodb::backup']
    Govuk_mount['/var/lib/mongo-sync'] -> Class['mongodb::server']
  }
}
