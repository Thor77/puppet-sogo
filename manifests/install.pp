# @summary Manage SoGO installation
# @api private
class sogo::install {
  package { $sogo::package_name:
    ensure => $sogo::package_ensure,
  }

  ensure_resource(package, $sogo::extra_packages, { ensure => $sogo::package_ensure })
}
