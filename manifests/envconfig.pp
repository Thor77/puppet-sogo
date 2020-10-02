# @summary Manage SoGo environment parameters
# @api private
class sogo::envconfig {
  if ! empty($sogo::envconfig) {
    file { $sogo::envconfig_path:
      ensure       => 'present',
      content      => epp('sogo/sogo.envconfig.epp', { envconfig => $sogo::envconfig }),
      validate_cmd => '/usr/bin/bash -n %',
      notify       => Service[$sogo::service_name],
    }
  }
}
