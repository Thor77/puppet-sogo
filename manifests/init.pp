# @summary SoGo init class
class sogo (
  String $package_name,
  String $package_ensure,
  Array[String] $extra_packages,
  String $service_name,
  String $service_ensure,
  String $config_path,
  Hash $config,
) {
  contain sogo::install
  contain sogo::config
  contain sogo::service
}
