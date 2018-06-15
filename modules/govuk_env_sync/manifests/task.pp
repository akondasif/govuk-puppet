# == Custom resource type: govuk_env_sync::cron_job
#
# Runs a backup of MongoDB to Amazon S3 as a cron job.
#
# [*user*]
#   The user to run the cronjob as.
#
define govuk_env_sync::task(
  $hour,
  $minute,
  $action,
  $dbms,
  $storagebackend,
  $temppath,
  $database,
  $url,
  $path,
  $name = $title,
) {

  require govuk_env_sync::aws_auth
  require govuk_env_sync::sync_script

  file { "${govuk_env_sync::conf_dir}/${name}.cfg":
    ensure  => present,
    mode    => '0755',
    owner   => $user,
    group   => $user,
    content => template('govuk_env_sync/govuk_env_sync_job.conf.erb'),
  }

  $synccommand = shellquote([
    '/usr/bin/ionice','-c','2','-n','6',
    '/usr/bin/setlock','/etc/unattended-reboot/no-reboot/govuk_env_sync',
    '/usr/bin/envdir',"${govuk_env_sync::conf_dir}/env.d",
    '/usr/local/bin/govuk_env_sync.sh','-f',"${name}.cfg",
    ])

  cron { $name:
    command => $synccommand,
    user    => $user,
    hour    => $hour,
    minute  => $minute,
    require => File["${govuk_env_sync::conf_dir}/${name}.cfg"],
  }

}
