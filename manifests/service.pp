# @summary Manage SoGo service
class sogo::service {
  service { $sogo::service_name:
    ensure  => $sogo::service_ensure,
    enable  => true,
    require => [
      Package[$sogo::package_name],
      File[$sogo::config_path],
    ],
  }
}
