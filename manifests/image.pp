# Definition: docker::image
#
# This class installs or removes docker images.
#
# Requires docker version >=1.3.1
#
# Parameters:
# Option parameters:
# ensure => true - pull a docker image
# ensure => false - remove docker image
# tag => '0.1.1' - pull/remove a specific tag for the repo default is 'latest'
#
# Requires:
# - docker class
#
# Sample Usage:
#    require docker
#
#    docker::image { 'ubuntu':
#      tag => '14.04'
#    }
#
define docker::image (
    $tag = 'latest',
    $ensure = true
) {
  validate_bool($ensure)
  validate_string($tag)

  #Defaults for types
  Exec {
    path => '/bin:/usr/bin',
  }

  if $ensure {
    #add image if its not there
    exec { "docker pull ${title}:${tag}":
      unless => "docker images ${title} | awk '{print \$2}' | grep ${tag}",
    }
  } else {
    #remove images if they exist
    exec { "docker rmi ${title}:${tag}":
      onlyif => "docker images -q ${title} | awk '{print \$2}' | grep ${tag}",
    }
  }
}
