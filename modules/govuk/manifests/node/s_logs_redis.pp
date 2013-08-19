class govuk::node::s_logs_redis inherits govuk::node::s_redis_base {
  @@nagios::check { "check_redis_list_logs${::hostname}":
    check_command       => "check_nrpe!check_redis_list!${::redis_port} LLEN,logs 10000 30000",
    service_description => 'redis list length for logs',
    host_name           => $::fqdn,
    notes_url           => 'https://github.gds/pages/gds/opsmanual/2nd-line/nagios.html#redis-server-check',
  }

  # tagalog on all nodes forward directly to here.
  @ufw::allow { 'allow-redis-from-anywhere':
    from => '10.0.0.0/8',
    port => $::redis_port;
  }

  # Each redis machine is used by govuk::logstream as a message broker
  # for log data from applications. The logging elasticsearch cluster needs a
  # river for each redis server to read the data into a logstash-compatible
  # index.
  @@elasticsearch::river { "logging-${::hostname}":
    content => template('govuk/redis_river.json.erb'),
    tag     => 'logging',
  }
}
