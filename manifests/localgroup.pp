define users_sys::localgroup (
  $ensure = present,
  $gid = undef,
  $allowdupe = false ) {

  case $::osfamily {
    Debian : {
      $supported = true
    }
    RedHat : {
      $supported = true
    }
    default : {
      $supported = false
      notify { "${module_name}_unsupported" :
        message => "The ${module_name} module is not supported on ${::operatingsystem}",
      }
    }
  }

  if ($supported == true) {
    if ($ensure == present) {
      group { $name :
        ensure    => present,
        gid       => $gid,
        allowdupe => $allowdupe
      }
    } elsif ($ensure == 'absent') {
      group { $name :
        ensure  => absent,
        require => User[$name]
      }
    } else {
      notify { "${module_name}_error" :
        message => 'Attribute ensure is required and  must ether \'absent\' or \'present\'',
      }
    }
  }

}
