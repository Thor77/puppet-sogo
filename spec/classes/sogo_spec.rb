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
        'SOGoUserSources' => [
          {
            'type'                  => 'sql',
            'id'                    => 'directory',
            'viewURL'               => 'postgresql://sogo@127.0.0.1/sogo/sogo_view',
            'canAuthenticate'       => 'YES',
            'isAddressBook'         => 'YES',
            'userPasswordAlgorithm' => 'md5',
          },
        ],
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

      it do
        is_expected.to contain_service('sogo') \
          .with_ensure('running') \
          .with_enable(true)
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

      it do
        is_expected.to contain_file('envconfig') \
          .with_content(%r{^PREFORK=15$}) \
          .that_notifies('Service[sogo]')
      end

      context 'with empty envconfig' do
        let(:params) { { 'envconfig' => {} } }

        it do
          is_expected.not_to contain_file('envconfig')
        end
      end
    end

    context "Multiple domains with multiple user sources on #{os}" do
      let(:facts) { os_facts }
      let :params do
        {
          'config' => {
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
            },
          },
        }
      end

      it do
        is_expected.to contain_file('/etc/sogo/sogo.conf') \
          .with_content(%r{id = addressbook;}) \
          .with_content(%r{id = directory;}) \
          .with_content(%r{\{\n  domains = \{\n    example.org = \{\n      SOGoSieveScriptsEnabled = NO;\n      SOGoUserSources = \(}) \
          .with_content(%r{    example.net = \{}) \
          .that_notifies('Service[sogo]')
      end
    end
  end
end
