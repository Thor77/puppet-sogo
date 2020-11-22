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
        'domains' => {
          'example.org' => {
            'SOGoSieveScriptsEnabled' => 'NO',
            'SOGoUserSources' => [
              {
                'type' => 'sql',
                'id' => 'directory',
                'viewURL' => 'postgresql://sogo@127.0.0.1/sogo/sogo_view',
              },
              {
                'type' => 'sql',
                'id' => 'addressbook',
                'viewURL' => 'postgresql://sogo@127.0.0.1/sogo/sogo_view_test',
              },
            ],
          },
          'example.net' => {
            'SOGoSieveScriptsEnabled' => 'YES',
            'SOGoUserSources' => [
              {
                'type' => 'sql',
                'id' => 'directory',
                'viewURL' => 'postgresql://sogo@127.0.0.1/sogo/sogo_view',
              },
              {
                'type' => 'sql',
                'id' => 'addressbook',
                'viewURL' => 'postgresql://sogo@127.0.0.1/sogo/sogo_view_test',
              },
            ],
          },
        }
      },
      envconfig => {
          'PREFORK' => 3,
      },
    }
  PUPPETCODE

  context 'on all systems' do
    apply_manifest(pp)

    describe package('sogo') do
      it { is_expected.to be_installed }
    end

    describe file('/etc/sogo/sogo.conf') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match %r{^\{\n  SOGoSieveScriptsEnabled = YES;\n  SOGoMailCustomFromEnabled = YES;} }
      its(:content) { is_expected.to match %r{^  domains = \{\n    example.org = \{\n      SOGoSieveScriptsEnabled = NO;\n      SOGoUserSources = \(} }
      its(:content) { is_expected.to match %r{^    example.net = \{} }
      its(:content) { is_expected.to match %r{^          id = directory;} }
      its(:content) { is_expected.to match %r{^          id = addressbook;} }
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

      describe port(20_000) do
        it { is_expected.to be_listening }
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

      describe port(20_000) do
        it { is_expected.to be_listening }
      end
    end
  end
end
