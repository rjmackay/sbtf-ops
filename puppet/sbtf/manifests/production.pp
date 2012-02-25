# vim: filetype=puppet
# "production" environment setup

class sbtf::production inherits sbtf::base {
    file { "/etc/hosts":
        ensure  => "present",
        content => "# WARNING: managed by puppet!
127.0.0.1       localhost localhost.localdomain\n",
        owner   => "root",
        group   => "root",
        mode    => "644",
    }

    server_user { "ushahidi":
        uid      => 5555,
        fullname => "Ushahidi System User",
        password => "locked",
    }

    file { "/home/ushahidi/.ssh/known_hosts":
        ensure  => present,
        content => "github.com,207.97.227.239 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==\n",
        owner   => "ushahidi",
        group   => "ushahidi",
        mode    => 644,
        require => User["ushahidi"],
    }

    # Admittedly, this doesn't really grant much security, the ushahidi user could
    # change the contents of this file to whatever they wanted.
    file { "/etc/sudoers.d/ushahidi":
        ensure  => present,
        content => "# WARNING: managed by puppet!
ushahidi   ALL=NOPASSWD: /home/ushahidi/sbtf-ops/bin/update-server.sh\n",
        owner   => "root",
        group   => "root",
        mode    => 440,
    }

    file { "/home/ushahidi/sbtf-ops/puppet/local.pp":
        ensure => present,
        owner  => "ushahidi",
        group  => "ushahidi",
        mode   => 644,
    }

    # SSH
    package { "ssh":
        ensure  => latest,
        require => Class["apt-setup"],
    }

    service { "ssh":
        hasrestart => true,
        ensure     => "running",
        require    => Package["ssh"],
    }

    augeas { "sshd_config":
        context => "/files/etc/ssh/sshd_config",
        changes => [
            "set PasswordAuthentication no",
            "set ChallengeResponseAuthentication no",
            "set PermitRootLogin no",
            "set ListenAddress 0.0.0.0",
            "set Port 22",
        ],
        notify  => Service["ssh"],
        require => Package["ssh"],
    }

    # NTP
    package { "ntp":
        ensure  => latest,
        require => Class["apt-setup"],
    }

    service { "ntp":
        ensure  => "running",
        require => Package["ntp"],
    }


    # Developer/admin accounts here

    server_user { "robbie":
            uid             => 2001,
            fullname        => "Robbie Mackay",
            groups          => [ "ushahidi", "admin" ],
            authorized_keys => "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAsGY/zd2QS36JKh979msu1jBi8ECGG+h8uAIJuAEoT2L5R1ol7ll4j08pNd3HT/QujlSkQ0DfT2+BZPx8+GjX2hyPGFtjyzOEc9bLyHN9pcu+8S8YQTol+auq/4+Us4QQsmeDl7+DMYTid6j7r5+Dg4aBeibQqunuv08LeYx0p2ZoqvHw/oZJSQdI1Pb3xCXQjh458A3WG22CGyWCrhv5HsIxcP3udF+tDTYHFWlO19P1lPf7Q1/sGSPlwtwU3NPw7aPJPu9/k1AqnMYAlF1nS8ZEB+jCtt+cqAcYoMm6pNqQv/1A9VAUhlbQJiEVD6JxT++O5KeM/X+ZlDBFxky8mw== robbie@rjmackay1.robbiemackay.com",
    }
}
