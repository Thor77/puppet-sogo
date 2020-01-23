# @summary SoGo init class
class sogo (
  String $package_name = $sogo::params::package_name,
) inherits sogo::params {
  contain sogo::install
}
