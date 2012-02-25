# vim: filetype=puppet
# Sets up environment for running ushahidi

class sbtf::ushahidi inherits sbtf::base {
    Package {
        ensure  => installed,
        require => Bulkpackage["web-packages"],
    }

    $web_packages = [
        "nginx",
        "php5-fpm",
        "php5-mysql",
        "php5-mcrypt",
        "php5-curl",
        "php5-imap",
        "php5-xcache",
    ]

    bulkpackage { "web-packages":
        packages => $web_packages,
        require  => Class["apt-setup"],
    }

    package { $web_packages: }

    # nginx
    service { "nginx":
        ensure  => running,
        require => Package["nginx"],
    }

    # TODO check whether there's hasreload/standard puppet stuff can trigger reloads
    exec { "nginx-reload":
        command     => "service nginx reload",
        refreshonly => true,
    }

    file { "/etc/nginx/nginx.conf":
        ensure  => "present",
        owner   => "root",
        group   => "root",
        mode    => 644,
        content => template("sbtf/nginx/nginx.conf.erb"),
        require => Package["nginx"],
        notify  => Service["nginx"],
    }

    file { "/etc/nginx/sites-enabled/default":
        ensure  => "absent",
        require => Package["nginx"],
        notify  => Service["nginx"],
    }

    # TODO will need to make an intelligent decision about server name
    file { "/etc/nginx/sites-enabled/ushahidi":
        ensure  => "present",
        owner   => "root",
        group   => "root",
        mode    => 644,
        content => template("sbtf/nginx/ushahidi.erb"),
        require => Package["nginx"],
        notify  => Service["nginx"], # TODO check this causes a reload only if changed
    }

    file { "/etc/init.d/php5-fpm":
        ensure  => "present",
        owner   => "root",
        group   => "root",
        mode    => 755,
        require => Package["php5-fpm"],
        notify => Service["php5-fpm"],
    }

    service { "php5-fpm":
        ensure  => running,
        require => [ File["/etc/init.d/php5-fpm"], Package["php5-fpm"] ],
    }

    file { "/etc/php5/conf.d/xcache.ini":
        ensure  => "present",
        owner   => "root",
        group   => "root",
        mode    => 644,
        content => template("sbtf/php/xcache.ini.erb"),
        require => Package["php5-xcache"],
        notify  => Service["php5-fpm"],
    }

    # Ushahidi
    exec { "checkout_ushahidi":
        command => "git clone git://github.com/rjmackay/Ushahidi_Web.git ushahidi --branch deployment/ted",
        cwd     => "/home/ushahidi",
        creates => "/home/ushahidi/ushahidi",
        user    => "ushahidi",
        group   => "ushahidi",
    }

    file { "/home/ushahidi/ushahidi/application/config/config.php":
        ensure  => "present",
        owner   => "ushahidi",
        group   => "ushahidi",
        mode    => 644,
        content => template("sbtf/ushahidi/config.php.erb"),
        require => Exec["checkout_ushahidi"],
    }

    file { "/home/ushahidi/ushahidi/application/config/cache.php":
        ensure  => "present",
        owner   => "ushahidi",
        group   => "ushahidi",
        mode    => 644,
        content => template("sbtf/ushahidi/cache.php.erb"),
        require => Exec["checkout_ushahidi"],
    }

    file {[
        "/home/ushahidi/ushahidi/application/cache",
        "/home/ushahidi/ushahidi/application/logs",
        "/home/ushahidi/ushahidi/media/uploads",
        ]:
        ensure  => "directory",
        owner   => "www-data",
        group   => "www-data",
        mode    => 600,
        require => Exec["checkout_ushahidi"],
    }

    file { "/etc/cron.d/ushahidi":
        ensure  => "present",
        owner   => "root",
        group   => "root",
        mode    => 644,
        content => template("sbtf/ushahidi/cron.erb"),
    }

    file {  "/var/log/ushahidi":
        ensure  => "directory",
        owner   => "root",
        group   => "root",
        mode    => 644,
    }

}
