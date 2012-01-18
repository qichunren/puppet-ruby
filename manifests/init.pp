class ruby($version = "1.9.3-p0", $url = "http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-$version.tar.gz") {
  rubyinstall { "$version":
    url => $url
  }
}

define rubyinstall($url) {
  $version = $title

  package { "libyaml-dev":
    ensure => latest
  }
  sourceinstall { "ruby-$version":
    tarball => $url,
    prefix => "/opt/ruby-$version",
    flags => "",
    bootstrap => "sh -c 'echo -e fcntl\\\\\\\\nopenssl\\\\\\\\nreadline\\\\\\\\nzlib >ext/Setup'",
    require => [
      Package["libyaml-dev"]
    ]
  }

  exec { "alternatives-ruby-$version":
    command => "update-alternatives --install /usr/bin/ruby ruby /opt/ruby-$version/bin/ruby 10 --slave /usr/bin/irb irb /opt/ruby-$version/bin/irb && update-alternatives --set ruby /opt/ruby-$version/bin/ruby",
    unless => "test /etc/alternatives/ruby -ef /opt/ruby-$version/bin/ruby && test /etc/alternatives/irb -ef /opt/ruby-$version/bin/irb",
    path => ["/usr/sbin", "/usr/bin", "/sbin", "/bin"],
    require => Sourceinstall["ruby-$version"]
  }
  exec { "alternatives-gem-$version":
    command => "update-alternatives --install /usr/bin/gem gem /opt/ruby-$version/bin/gem 10 && update-alternatives --set gem /opt/ruby-$version/bin/gem",
    unless => "test /etc/alternatives/gem -ef /opt/ruby-$version/bin/gem",
    path => ["/usr/sbin", "/usr/bin", "/sbin", "/bin"],
    require => Exec["alternatives-ruby-$version"]
  }
  exec { "alternatives-rake-$version":
    command => "update-alternatives --install /usr/bin/rake rake /opt/ruby-$version/bin/rake 10 && update-alternatives --set rake /opt/ruby-$version/bin/rake",
    unless => "test /etc/alternatives/rake -ef /opt/ruby-$version/bin/rake",
    path => ["/usr/sbin", "/usr/bin", "/sbin", "/bin"],
    require => Exec["alternatives-ruby-$version"]
  }

  exec { "gem-install-bundler-$version":
    command => "gem install bundler",
    unless => "gem list | grep bundler",
    timeout => "-1",
    path => ["/usr/sbin", "/usr/bin", "/sbin", "/bin"],
    require => Exec["alternatives-gem-$version"]
  }
  exec { "alternatives-bundle-$version":
    command => "update-alternatives --install /usr/bin/bundle bundle /opt/ruby-$version/bin/bundle 10 && update-alternatives --set bundle /opt/ruby-$version/bin/bundle",
    unless => "test /etc/alternatives/bundle -ef /opt/ruby-$version/bin/bundle",
    path => ["/usr/sbin", "/usr/bin", "/sbin", "/bin"],
    require => Exec["gem-install-bundler-$version"]
  }
}
