# vim: filetype=puppet
# Sets up apt configuration for all nodes

class sbtf::apt-setup inherits sbtf::local-settings {
    File {
        ensure => "present",
        owner  => "root",
        group  => "root",
        mode   => "644",
    }

    exec { "apt-get_update":
        command     => "/usr/bin/apt-get update",
        require     => [ File["norecommends"],
                         File["defaultrelease"],
                         # These are not true dependencies, but we want them to
                         # happen before most other actions, and the puppet in
                         # lucid doesn't support run stages
                         Exec["reconfigure_locales"],
                         File["/etc/localtime"],
                       ],
        refreshonly => true,
    }

    file { "norecommends":
        path    => "/etc/apt/apt.conf.d/02norecommends",
        content => "APT::Install-Recommends \"0\";",
    }

    file { "defaultrelease":
        path    => "/etc/apt/apt.conf.d/03defaultrelease",
        content => "APT::Default-Release \"lucid\";",
    }

    # NOTE: not using the ec2 mirror here, since the aim is for the puppet to
    # be usable anywhere.
    file { "/etc/apt/sources.list":
        notify => Exec["apt-get_update"],
        content => $envtype ? {
            production => "# WARNING: managed via puppet
deb http://archive.ubuntu.com/ubuntu  lucid main restricted universe
deb http://archive.ubuntu.com/ubuntu  lucid-updates main restricted universe
deb http://security.ubuntu.com/ubuntu lucid-security main restricted universe
",
            private => "# WARNING: managed via puppet
deb $ubuntu_mirror lucid main universe
deb-src $ubuntu_mirror lucid main universe
deb $ubuntu_mirror lucid-updates main universe
deb-src $ubuntu_mirror lucid-updates main universe
deb $ubuntu_mirror lucid-security main universe
deb-src $ubuntu_mirror lucid-security main universe
",
        },
        require => File["/etc/apt/apt.conf.d/02norecommends"],
    }

    # Adding the key for the nginx ppa
    exec { "apt-key_nginx_ppa":
        command     => "/usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C",
        refreshonly => true,
    }

    # Adding the nginx ppa for php5 so we get php5-fpm
    file { "/etc/apt/sources.list.d/nginx-ppa-php5.list":
        notify => Exec["apt-key_nginx_ppa", "apt-get_update"],
        content => $envtype ? {
            production => "# WARNING: managed via puppet
deb http://ppa.launchpad.net/nginx/php5.3/ubuntu lucid main
",
            private => "# WARNING: managed via puppet
deb http://ppa.launchpad.net/nginx/php5.3/ubuntu lucid main
deb-src http://ppa.launchpad.net/nginx/php5.3/ubuntu lucid main
",
        },
        require => File["/etc/apt/apt.conf.d/02norecommends"],
    }

}
