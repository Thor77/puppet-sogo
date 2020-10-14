# @summary Manage SoGo service
# @api private
class sogo::service {
  service { 'sogo':
    ensure  => $sogo::service_ensure,
    name    => $sogo::service_name,
    enable  => true,
    require => [
      Package[$sogo::package_name],
      File[$sogo::config_path],
    ],
  }
}
