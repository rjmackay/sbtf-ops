# vim: filetype=puppet
# Base class for all roles

class sbtf::base {
    Exec {
        path => "/usr/sbin:/usr/bin:/sbin:/bin",
    }
    
	# todo: add hostname here?
    file { "/etc/hosts":
        ensure  => "present",
        content => "# WARNING: managed by puppet!
127.0.0.1       localhost localhost.localdomain\n",
        owner   => "root",
        group   => "root",
        mode    => "644",
    }

    $repo_path = inline_template('<%= Dir.pwd %>')

    include sbtf::apt-setup

    # Think this needs to be usr/share/i18n/supported
    # Configure locales
    #file { "/var/lib/locales/supported.d/local":
    #    ensure  => "present",
    #    owner   => "root",
    #    group   => "root",
    #    mode    => "644",
    #    content => "en_US.UTF-8 UTF-8\n",
    #}

    #exec { "reconfigure_locales":
    #    command     => "/usr/sbin/dpkg-reconfigure locales",
    #    subscribe   => File["/var/lib/locales/supported.d/local"],
    #    refreshonly => true,
    #}

    # Configure timezone
    file { "/etc/localtime":
        ensure => "/usr/share/zoneinfo/UTC",
    }

    # Useful
    package { [
        "git-core",                     # Needed for updating repos
        "python-software-properties",   # Needed for add-apt-repository
        ]:
        ensure  => latest,
        require => Class["apt-setup"],
    }

    # Cron job(s)
    package { "cron":
        ensure  => latest,
        require => Class["apt-setup"],
    }

    service { "cron":
        ensure  => running,
        require => Package["cron"],
    }

    # Logrotate
    package { "logrotate":
        ensure  => latest,
        require => Class["apt-setup"],
    }
}
