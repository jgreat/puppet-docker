# Definition: docker::container
#
# This class installs docker containers using a custom provider for service.
#
# Requires docker version >=1.3.1
#
# Parameters:
# Required parameters:
# - image - docker image name with optional tag "ubuntu:14.04"
# Option parameters:
# - See 'docker create' options:
#     http://docs.docker.com/reference/commandline/cli/#create
# - Accepts most options documented.
# - If an option is not avalible you can pass in additonal options with
#   extra_parameters => [ '--option=foo', '--other=bar' ]
#
# Yes this is a total cop out on the docs, but docker options are a fast
# moving target.
#
# Actions:
#
# Writes a "config" file to /etc/docker/$title.config with the various docker
# options, then creates a service with the provider "docker" to start, stop and
# maintain the container.
# The Service:
# enable => true - 'docker create $title'
# enable => false - 'docker rm $title'
# ensure => running - 'docker start $title'
# ensure => stopped - 'docker stop $title'
# refresh action - stop, rm, create, start
#
# Requires:
# - docker class
#
# Sample Usage:
#    require docker
#
#    docker::container { 'logspout':
#      image    => 'progrium/logspout',
#      command  => "syslog://logs.example.com:22000",
#      volume   => [ '/var/run/docker.sock:/tmp/docker.sock' ],
#      publish  => [ '127.0.0.1:8000:8000' ],
#      hostname => $::fqdn,
#      dns      => [ '8.8.8.8', '8.8.4.4' ],
#    }
#
define docker::container (
  $image,
  $attach = [],
  $add_host = [],
  $cap_add = [],
  $cap_drop = [],
  $command = undef,
  $cpu_set = undef,
  $cpu_shares = undef,
  $device = [],
  $dns = [],
  $dns_search = [],
  $env = [],
  $entrypoint = undef,
  $env_file = [],
  $expose = [],
  $extra_parameters = [],
  $hostname = undef,
  $interactive = false,
  $link = [],
  $lxc_conf = [],
  $memory_limit = undef,
  $net = undef,
  $publish = [],
  $publish_all = false,
  $privileged = false,
  $restart = 'always',
  $security_opt = [],
  $tty = false,
  $user = undef,
  $volume = [],
  $volumes_from = [],
  $workdir = undef,
) {
  validate_array($attach)
  validate_array($add_host)
  validate_array($cap_add)
  validate_array($cap_drop)
  #cidfile not needed
  validate_string($command)
  validate_string($cpu_set)
  validate_string($cpu_shares)
  validate_array($device)
  validate_array($dns)
  validate_array($dns_search)
  validate_array($env)
  validate_string($entrypoint)
  validate_array($env_file)
  validate_array($expose)
  validate_string($hostname)
  validate_bool($interactive)
  validate_string($image)
  validate_array($link)
  validate_array($lxc_conf)
  validate_string($memory_limit)
  #name is always defined as title
  validate_string($net)
  validate_array($publish)
  validate_bool($publish_all)
  validate_bool($privileged)
  validate_string($restart)
  validate_array($security_opt)
  validate_bool($tty)
  validate_string($user)
  validate_array($volume)
  validate_array($volumes_from)
  validate_string($workdir)

  #Other params that docker create might add
  validate_array($extra_parameters)

  $config_dir = '/etc/docker'
  $config_file = "${config_dir}/${title}.config"

  if (! defined(File[$config_dir])) {
    file { $config_dir:
      ensure => directory,
    }
  }
  file { $config_file:
    ensure  => file,
    mode    => '0600',
    content => template('docker/etc/docker/docker.config.erb'),
    require => File[$config_dir],
    notify  => Service[$title],
  }
  service { $title:
    ensure     => running,
    enable     => true,
    provider   => 'docker',
    manifest   => $config_file,
    require    => File[$config_file],
  }
}
