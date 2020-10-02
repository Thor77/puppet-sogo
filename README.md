# puppet-sogo

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
        'SOGoUserSources' => {
            'type' => 'sql',
            'id' => 'directory',
            'viewURL' => "${database}/sogo_view",
            'canAuthenticate' => 'YES',
            'isAddressBook' => 'YES',
            'userPasswordAlgorithm' => 'md5',
        },
    },
    envconfig => {
        'PREFORK' => 3,
    },
}
```

## Limitations
* no unit/integration tests
* only tested on Debian 10
