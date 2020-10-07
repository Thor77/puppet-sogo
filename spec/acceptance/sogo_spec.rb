require 'spec_helper_acceptance'

describe '::sogo' do
  pp = <<-PUPPETCODE
    $database = 'postgresql://sogo@127.0.0.1/sogo'

    case $facts['os']['family'] {
      'RedHat': {
        $extra_packages = ['sope49-gdl1-postgresql']
        if versioncmp($facts['os']['release']['major'], '7') >= 0 {
          file_line { 'fix_sogo_systemd_unit':
            ensure => 'absent',
            path => '/usr/lib/systemd/system/sogod.service',
            line => 'PIDFile=/var/run/sogo/sogo.pid',
            notify => Service['sogod'],
          }
        }
      }
      'Debian': {
	$extra_packages = ['sope4.9-gdl1-postgresql']
      }
      default: { warning('Only prepared for Debian and RedHat based systems') }
    }

    class { 'sogo':
      extra_packages => $extra_packages,
      config => {
          'SOGoSieveScriptsEnabled' => 'YES',
          'SOGoMailCustomFromEnabled' => 'YES',
          'SOGoUserSources' => {
              'type' => 'sql',
              'id' => 'directory',
              'viewURL' => "${database}/sogo_view",
          },
      },
      envconfig => {
          'PREFORK' => 3,
      },
    }
  PUPPETCODE

  context 'on all systems default parameters' do
    apply_manifest(pp)

    describe package('sogo') do
      it { is_expected.to be_installed }
    end

    describe file('/etc/sogo/sogo.conf') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match %r{SOGoUserSources = \(\n    \{\n      type = sql;} }
    end
  end

  context 'on redhat/oracle systems' do
    if os[:family] =~ %r{redhat|oracle}

      idempotent_apply(pp)

      describe service('sogod') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end

      describe file('/etc/sysconfig/sogo') do
        it { is_expected.to be_file }
        its(:content) { is_expected.to match %r{^PREFORK=3$} }
      end
    end
  end

  context 'on debian/ubuntu systems' do
    if os[:family] =~ %r{debian|ubuntu}

      idempotent_apply(pp)

      describe service('sogo') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end

      describe file('/etc/default/sogo') do
        it { is_expected.to be_file }
        its(:content) { is_expected.to match %r{^PREFORK=3$} }
      end
    end
  end
end
