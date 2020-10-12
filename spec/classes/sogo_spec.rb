require 'spec_helper'

describe 'sogo' do
  params_hash =
    {
      'extra_packages' => ['sope4.9-gdl1-postgresql', 'sogo-tool'],
      'envconfig' => {
        'PREFORK' => 15,
      },
      'config' => {
        'SOGoProfileURL'            => 'postgresql://sogo@127.0.0.1/sogo/sogo_user_profile',
        'OCSFolderInfoURL'          => 'postgresql://sogo@127.0.0.1/sogo/sogo_folder_info',
        'OCSSessionsFolderURL'      => 'postgresql://sogo@127.0.0.1/sogo/sogo_sessions_folder',
        'SOGoSieveScriptsEnabled'   => 'YES',
        'SOGoMailCustomFromEnabled' => 'YES',
        'SOGoUserSources' => {
          'type'                  => 'sql',
          'id'                    => 'directory',
          'viewURL'               => 'postgresql://sogo@127.0.0.1/sogo/sogo_view',
          'canAuthenticate'       => 'YES',
          'isAddressBook'         => 'YES',
          'userPasswordAlgorithm' => 'md5',
        },
      },
    }
  let(:params) { params_hash }
  let(:hiera_config) { 'spec/fixtures/hiera.yaml' }

  on_supported_os.each do |os, os_facts|
    context "Generic tests for #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('sogo::config') }
      it { is_expected.to contain_class('sogo::envconfig') }
      it { is_expected.to contain_class('sogo::install') }
      it { is_expected.to contain_class('sogo::service') }
      it { is_expected.to contain_package('sogo').with_ensure('installed') }
      it do
        params_hash['extra_packages'].each do |extra_package|
          is_expected.to contain_package(extra_package) \
            .with_ensure('installed')
        end
      end
    end
  end

  context 'on a Debian OS' do
    let :facts do
      {
        os: {
          family: 'Debian',
        },
      }
    end

    it do
      is_expected.to contain_service('sogo') \
        .with_ensure('running') \
        .with_enable(true)
    end

    it do
      is_expected.to contain_file('/etc/default/sogo') \
        .with_content(%r{^PREFORK=15$}) \
        .that_notifies('Service[sogo]')
    end

    it do
      is_expected.to contain_file('/etc/sogo/sogo.conf') \
        .with_content(%r{OCSSessionsFolderURL = postgresql://sogo@127.0.0.1/sogo/sogo_sessions_folder;}) \
        .that_notifies('Service[sogo]')
    end

    it do
      is_expected.to contain_file('/etc/sogo/sogo.conf') \
        .with_content(%r{SOGoUserSources = \(\n    \{\n      type = sql;}) \
        .that_notifies('Service[sogo]')
    end

    context 'with empty envconfig' do
      let(:params) { { 'envconfig' => {} } }

      it do
        is_expected.not_to contain_file('/etc/default/sogo')
      end
    end

    context 'with multiple SOGoUserSources' do
      let :params do
        {
          'config' => {
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
      end

      it do
        is_expected.to contain_file('/etc/sogo/sogo.conf') \
          .with_content(%r{id = addressbook;}) \
          .with_content(%r{id = directory;}) \
          .that_notifies('Service[sogo]')
      end
    end
  end

  context 'on a RedHat OS' do
    let :facts do
      {
        os: {
          family: 'RedHat',
        },
      }
    end

    it do
      is_expected.to contain_service('sogod') \
        .with_ensure('running') \
        .with_enable(true)
    end

    it do
      is_expected.to contain_file('/etc/sysconfig/sogo') \
        .with_content(%r{^PREFORK=15$}) \
        .that_notifies('Service[sogod]')
    end

    it do
      is_expected.to contain_file('/etc/sogo/sogo.conf') \
        .with_content(%r{OCSSessionsFolderURL = postgresql://sogo@127.0.0.1/sogo/sogo_sessions_folder;}) \
        .that_notifies('Service[sogod]')
    end

    it do
      is_expected.to contain_file('/etc/sogo/sogo.conf') \
        .with_content(%r{SOGoUserSources = \(\n    \{\n      type = sql;}) \
        .that_notifies('Service[sogod]')
    end

    context 'with empty envconfig' do
      let(:params) { { 'envconfig' => {} } }

      it do
        is_expected.not_to contain_file('/etc/sysconfig/sogo')
      end
    end

    context 'with multiple SOGoUserSources' do
      let :params do
        {
          'config' => {
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
      end

      it do
        is_expected.to contain_file('/etc/sogo/sogo.conf') \
          .with_content(%r{id = addressbook;}) \
          .with_content(%r{id = directory;}) \
          .that_notifies('Service[sogod]')
      end
    end
  end
end
