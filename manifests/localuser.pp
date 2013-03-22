define users_sys::localuser (
  $allowdupe = undef,
  $comment = undef,
  $ensure = present,
  $expiry = undef,
  $gid = $name,
  $groups = undef,
  $home = "/home/${name}",
  $managehome = false,
  $password = undef,
  $shell = '/bin/bash',
  $system = false,
  $uid = undef,
  $ssh_authorized_key = undef,
  $ssh_authorized_key_type = 'ssh-rsa',
  $ssh_authorized_key_options = undef ) {

  case $::osfamily {
    Debian: {
      $supported = true
      $lockstatus = 'L'
    }
    RedHat: {
      $supported = true
      $lockstatus = 'LK'
    }
    default: {
      $supported = false
      notify { "${module_name}_unsupported":
        message => "The ${module_name} module is not supported on ${::operatingsystem}",
      }
    }
  }

  if ($supported == true) {
    if ($ensure == present) {
    group { $name:
          ensure    => present,
          gid       => $gid ? {
            $name   => undef,
            default => $gid
          },
          allowdupe => $allowdupe
      }
      user { $name:
        ensure     => present,
        comment    => $comment,
        expiry     => $expiry,
        uid        => $uid,
        gid        => $gid,  
        groups     => $groups,
        home       => $home,
        managehome => $managehome,
        shell      => $shell,
        system     => $system,
        require    => Group[$name]
      }
      if ($password != undef) {
        exec { "usermod -p \'${password}\' ${name} && chage -d 0 ${name}":
          path    => '/usr/sbin:/sbin:/usr/bin:/bin',
          unless  => "test ! \"$(passwd -S ${name} | cut -d ' ' -f2)\" = \"${lockstatus}\"",
          require => User[$name]
        }
      }
      if ($ssh_authorized_key != undef) {
        ssh_authorized_key { $name:
          ensure  => present,
          key     => $ssh_authorized_key,
          type    => $ssh_authorized_key_type,
          user    => $name,
          options => $ssh_authorized_key_type_options,
          require => User[$name]
        }
      }
    } elsif ($ensure == 'absent') {
      if ($ssh_authorized_key != undef) {
        ssh_authorized_key { $name:
          ensure => absent,
          user   => $name,
        }
        user { $name:
          ensure  => absent,
          require => Ssh_authorized_key[$name],
        }
        group { $name:
          ensure  => absent,
          require => User[$name]
        }
      } else {
        user { $name:
          ensure => absent,
        }
        group { $name:
          ensure  => absent,
          require => User[$name]
        }
      }
    } else {
      notify { "${module_name}_error":
        message => 'Attribute ensure is required and  must ether \'absent\' or \'present\'',
      }
    }
  }
}
