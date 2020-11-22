# @summary Manage SoGo configuration
# @api private
class sogo::config {
  $_header = "//\n// Managed by Puppet\n//\n"
  $_hash = plgen($sogo::config)
  $_content = "${_header}\n{\n${_hash}}\n"

  file { $sogo::config_path:
    ensure       => 'present',
    content      => $_content,
    validate_cmd => '/usr/bin/plparse %',
    notify       => Service[$sogo::service_name],
  }
}
