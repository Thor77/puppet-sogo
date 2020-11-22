# puppet-sogo
[![Build Status](https://travis-ci.com/Thor77/puppet-sogo.svg?branch=master)](https://travis-ci.com/Thor77/puppet-sogo)
[![Puppet Forge](https://img.shields.io/puppetforge/v/thor77/sogo.svg)](https://forge.puppetlabs.com/thor77/sogo)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/thor77/sogo.svg)](https://forge.puppetlabs.com/thor77/sogo)



Module to manage [SOGo groupware](https://sogo.nu/)

## Example

```puppet
$database = 'postgresql://sogo@127.0.0.1/sogo'

class { 'sogo':
    # postgresql support
    extra_packages => ['sope4.9-gdl1-postgresql'],
    config => {
        'SOGoProfileURL' => "${database}/sogo_user_profile",
        'OCSFolderInfoURL' => "${database}/sogo_folder_info",
        'OCSSessionsFolderURL' => "${database}/sogo_sessions_folder",
        'SOGoSieveScriptsEnabled' => 'YES',
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
    envconfig => {
        'PREFORK' => 3,
    },
}
```

Multiple user sources can be defined as an array of hashes

```puppet
class { 'sogo':
...
    config => {
        'SOGoUserSources' => [
          {
            'type' => 'sql',
            'id' => 'directory',
            'viewURL' => "${database}/sogo_view",
            'canAuthenticate' => 'YES',
            'isAddressBook' => 'YES',
            'userPasswordAlgorithm' => 'md5',
          },
          {
            'type' => 'sql',
            'id' => 'addressbook',
            'viewURL' => "${database}/sogo_view_addresses",
            'canAuthenticate' => 'NO',
            'isAddressBook' => 'YES',
          },
        ],
    }
...
}
```

Multidomain example

```puppet
class { 'sogo':
...
    config => {
      'domains' => {
        'example.org' => {
          'SOGoSieveScriptsEnabled' => 'NO',
          'SOGoUserSources' => [
            {
              'type' => 'sql',
              'id' => 'directory',
              'viewURL' => 'postgresql://sogo@127.0.0.1/sogo/sogo_view',
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
          ],
        },
      },
    }
...

```
