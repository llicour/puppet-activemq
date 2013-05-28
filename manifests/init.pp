# Apache ActiveMQ AMQP message broker
# I use it for the message broker of MCollective (server orchestration)

class activemq($mqbrokerip01 = '192.168.0.16', $mqbrokerip02 = '192.168.0.21') {
    include java
    include yum::kermit

    package { 'tanukiwrapper' :
        ensure  => installed,
        require => [  Package[ 'java-1.6.0-openjdk' ],
                      Yumrepo[ 'kermit-custom', 'kermit-thirdpart' ], ],
    }

    package { 'activemq' :
        ensure  => installed,
        require => Package[ 'tanukiwrapper' ],
    }

    package { 'activemq-info-provider' :
        ensure  => installed,
        require => Package[ 'activemq' ],
    }

    file { '/etc/activemq/activemq.xml' :
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Service[ 'activemq' ],
        content => template( 'activemq/activemq.xml' ),
        require => Package[ 'activemq-info-provider' ],
    }

    file { '/etc/httpd/conf.d/activemq-httpd.conf' :
        ensure  => present,
        source  => 'puppet:///modules/activemq/activemq-httpd.conf',
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        require => Package['activemq'],
    }

    service { 'activemq' :
        ensure  => running,
        enable  => true,
        require => [  Package['activemq-info-provider' ],
                      File['/etc/activemq/activemq.xml' ], ],
    }

    include myfirewall

    firewall { '100 Stomp' :
          chain  => 'INPUT',
          proto  => 'tcp',
          state  => 'NEW',
          dport  => '6163',
          action => 'accept',
    }

    firewall { '101 OpenWire' :
          chain  => 'INPUT',
          proto  => 'tcp',
          state  => 'NEW',
          dport  => '6166',
          action => 'accept',
    }

    firewall { '102 ActiveMQ Web Console' :
          chain  => 'INPUT',
          proto  => 'tcp',
          state  => 'NEW',
          dport  => '8161',
          action => 'accept',
    }

}
