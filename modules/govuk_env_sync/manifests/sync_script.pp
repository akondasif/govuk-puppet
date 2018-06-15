# == Class: govuk_env_sync::sync_script
#
# Restore a MongoDB backup to a server from s3
#
# === Parameters:
#
# [*aws_access_key_id*]
#   Key used to sign programmatic requests in AWS
#
# [*aws_secret_access_key*]
#   Key used to sign programmatic requests in AWS
#
# [*env_dir*]
#   Defines directory for the environment
#   variables
#
class govuk_env_sync::sync_script
{

  # sync script
  #
  file { '/usr/local/bin/govuk-env-sync.sh':
    ensure => present,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/govuk_env_sync/govuk-env-sync.sh',
  }

}
