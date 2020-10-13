# @summary Manage SoGo environment parameters
# @api private
class sogo::envconfig {
  if ! empty($sogo::envconfig) {
    file { 'envconfig':
      ensure       => 'present',
      name         => $sogo::envconfig_path,
      content      => epp('sogo/sogo.envconfig.epp', { envconfig => $sogo::envconfig }),
      validate_cmd => '/bin/bash -n %',
      notify       => Service[$sogo::service_name],
    }
  }
}
