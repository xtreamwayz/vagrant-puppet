define php::ext (
    $extension_name = $title,
    $ensure         = $php::params::ensure,
    $ini_changes    = undef
) {

    include php
    include php::params

    if defined(Service['php-fpm-service']) {
        $notify = Service['php-fpm-service']
    } else {
        $notify = undef
    }

    if $ensure == purged {
        exec { "php-ext-disable-${extension_name}":
            command => "php5dismod ${extension_name}",
            onlyif  => "test -f ${cli_mod_path}/20-${extension_name}.ini -o -f ${fpm_mod_path}/20-${extension_name}.ini",
            require => Package['php-common'],
            notify  => $notify
        }
    }

    package { "${php::params::prefix}-${extension_name}":
        ensure  => $ensure,
        require => Package['php-common'],
        notify  => $notify
    }

    if $ini_changes {
        augeas { "${php::params::prefix}-${extension_name}-ini":
            lens => 'PHP.lns',
            incl => "${php::params::ext_path}/${extension_name}.ini",
            changes => $ini_changes,
            require => Package["${php::params::prefix}-${extension_name}"],
            notify => $notify
        }
    }

    # Dependencies
    Package <| title=='php-cli' |> ->
    Package <| title=='php-fpm' |> ->
    Package["${php::params::prefix}-$extension_name"]
}
