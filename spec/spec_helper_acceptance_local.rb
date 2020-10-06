# frozen_string_literal: true

class LitmusHelper
  include PuppetLitmus
end

module PrepareSogoEnvironment
  def install_requirements
    LitmusHelper.run_shell('puppet module install puppetlabs/apt')

    pre_pp = <<-PUPPETCODE
      if $::osfamily == 'Debian' {
        package { 'lsb-release':
          ensure   => 'installed'
        }
      }
    PUPPETCODE

    pp = <<-PUPPETCODE
      case $facts['os']['family'] {
        'RedHat': {
          if $facts['os']['name'] == 'OracleLinux' {
            if versioncmp($facts['os']['release']['major'], '7') >= 0 {
              package { "oracle-epel-release-el${facts['os']['release']['major']}":
                ensure   => 'installed'
              }
            }
          } else {
            package { 'epel-release':
              ensure   => 'installed'
            }
          }
          yumrepo { "sogo-rhel-${facts['os']['release']['major']}":
            baseurl => "https://packages.inverse.ca/SOGo/nightly/5/rhel/${facts['os']['release']['major']}/\\$basearch",
            gpgkey => 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xb022c48d3d6373d7fc256a8ccb2d3a2aa0030e2c',
            gpgcheck => false
          }
        }
        'Debian': {
          include apt
          $osname_lower = downcase($facts['os']['name'])
          # Dirty workaround for https://sogo.nu/bugs/view.php?id=4776
          file { '/usr/share/doc/sogo/':
            ensure => directory
          }->
          file { '/usr/share/doc/sogo/empty.sh':
            ensure => present,
            content => '# keepme - https://sogo.nu/bugs/view.php?id=4776'
          }
          apt::source { 'sogo':
            location => "http://packages.inverse.ca/SOGo/nightly/5/${osname_lower}/",
            repos => "$lsbdistcodename",
            key => {
              id => 'FE9E84327B18FF82B0378B6719CDA6A9810273C4',
              server => 'keyserver.ubuntu.com',
            }
          }
        }
        default: { warning('Only prepared for Debian and RedHat based systems') }
      }
    PUPPETCODE

    LitmusHelper.apply_manifest(pre_pp)
    LitmusHelper.apply_manifest(pp)
  end
end
