# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class govuk::python {
  # FIXME: Use an internal package for python-pip on Lucid due to 01b7f11.
  include govuk::repository

  class { '::python':
    pip        => true,
    dev        => true,
    virtualenv => true,
  }

  Class['python::install'] -> Package <| provider == 'pip' and ensure != absent |>
}
