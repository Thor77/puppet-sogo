# @summary Manage SoGo environment parameters
# @api private
class sogo::sysconfig {
  file { $sogo::sysconfig_path:
    ensure       => 'present',
    content      => epp('sogo/sogo.sysconfig.epp', { sysconfig => $sogo::sysconfig }),
    validate_cmd => '/usr/bin/bash -n %',
    notify       => Service[$sogo::service_name],
  }
}
