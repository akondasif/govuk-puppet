class nginx($node_type = 'UNSET') {

  anchor { 'nginx::begin':
    before => Class['nginx::package'],
    notify => Class['nginx::service'];
  }

  class { 'nginx::package':
    notify => Class['nginx::service'];
  }

  class { 'nginx::config':
    node_type => $node_type,
    require   => Class['nginx::package'],
    notify    => Class['nginx::service'];
  }

  class { 'nginx::service': }

  anchor { 'nginx::end':
    require => Class['nginx::service'],
  }
}
