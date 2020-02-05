# @summary Manage SoGo configuration
class sogo::config {
  file { $sogo::config_path:
    ensure       => 'present',
    content      => epp('sogo/sogo.conf.epp', { config => $sogo::config }),
    validate_cmd => '/usr/bin/plparse %',
    notify       => Service[$sogo::service_name],
  }
}
