# @summary Manage SoGO installation
class sogo::install {
  package { $sogo::package_name:
    ensure => 'installed',
  }
}
