# @summary SoGo init class
#
# @param [String] package_name Name of the SOGo package
# @param [String] package_ensure Ensure for package resource
# @param [Array[String]] extra_packages
#   Additional packages to install using package_ensure as ensure value
# @param [String] service_name Name of the SOGo service
# @param [String] service_ensure Ensure for service resource
# @param [String] config_path Path to configuration file
# @param [String] envconfig_path path to environment configuration
# @param [Hash] config SOGo configuration
# @param [Hash] envconfig environment configuration
class sogo (
  String $package_name,
  String $package_ensure,
  Array[String] $extra_packages,
  String $service_name,
  String $service_ensure,
  String $config_path,
  String $envconfig_path,
  Hash $config,
  Hash $envconfig,
) {
  contain sogo::install
  contain sogo::config
  contain sogo::envconfig
  contain sogo::service
}
