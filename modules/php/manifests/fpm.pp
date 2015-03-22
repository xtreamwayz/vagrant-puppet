class php::fpm (
    $ensure      = $php::params::ensure,
    $ini_changes = $php::params::fpm_ini_changes
) inherits php::params {

    include php

    package { 'php-fpm':
        name    => "${php::params::prefix}-fpm",
        ensure  => $ensure,
        require => Package['php-common']
    }

    service { 'php-fpm-service':
        name    => "${php::params::prefix}-fpm",
        ensure  => running,
        require => Package['php5-fpm']
    }

    augeas { 'php-fpm-ini':
        lens    => 'PHP.lns',
        incl    => "${php::params::fpm_ini}",
        changes => $ini_changes,
        require => Package['php-fpm'],
        notify  => Service['php-fpm-service']
    }
}