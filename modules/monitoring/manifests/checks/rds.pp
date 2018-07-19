# == Class: monitoring::checks::rds
#
# Nagios alerts for AWS RDS.
#
# === Parameters
#
# [*servers*]
#   List of RDS instances.
#
# [*enabled*]
#   This variable enables to define whether to perform Icinga RDS checks.
#
class monitoring::checks::rds (
      $enabled = true,
      $servers = [],
    ) {

    icinga::plugin { 'check_aws_rds_cpu':
        source  => 'puppet:///modules/monitoring/usr/lib/nagios/plugins/check_aws_rds_cpu',
        require => Package['boto'],
    }

    icinga::check_config { 'check_aws_rds_cpu':
        source  => 'puppet:///modules/monitoring/etc/nagios3/conf.d/check_aws_rds_cpu.cfg',
        require => File['/usr/lib/nagios/plugins/check_aws_rds_cpu'],
    }

    icinga::plugin { 'check_aws_rds_memory':
        source  => 'puppet:///modules/monitoring/usr/lib/nagios/plugins/check_aws_rds_memory',
        require => Package['boto'],
    }

    icinga::check_config { 'check_aws_rds_memory':
        source  => 'puppet:///modules/monitoring/etc/nagios3/conf.d/check_aws_rds_memory.cfg',
        require => File['/usr/lib/nagios/plugins/check_aws_rds_memory'],
    }

    icinga::plugin { 'check_aws_rds_storage':
        source  => 'puppet:///modules/monitoring/usr/lib/nagios/plugins/check_aws_rds_storage',
        require => Package['boto'],
    }

    icinga::check_config { 'check_aws_rds_storage':
        source  => 'puppet:///modules/monitoring/etc/nagios3/conf.d/check_aws_rds_storage.cfg',
        require => File['/usr/lib/nagios/plugins/check_aws_rds_storage'],
    }

    if $enabled {
      monitoring::checks::rds_config { $servers: }
    }
}
