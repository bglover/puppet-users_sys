class users_sys {
  $users = hiera_array("${module_name}::users",undef)
  $groups = hiera_array("${module_name}::groups",undef)
  $users_settings = hiera_hash("${module_name}::users_settings",undef)
  $groups_settings = hiera_hash("${module_name}::groups_settings",undef)
  $user_defaults = hiera_hash("${module_name}::user_defaults",undef)
  $group_defaults = hiera_hash("${module_name}::group_defaults",undef)


  if $users_settings {
    if $user_defaults {
      create_resources("@${module_name}::localuser",$users_settings,$user_defaults)
    }
  } elsif ($users != undef) {
    @localuser { $users: }
  }

  if $groups_settings {
    if $group_defaults {
      create_resources("@${module_name}::localgroup",$groups_settings,$group_defaults)
    } else {
      create_resources("@${module_name}::localgroup",$groups_settings)
    }
  } elsif $groups {
    @localgroup { $groups: }
  }

  if $users {
    realize(Localuser[$users])
  }
  if $groups {
    realize(Localgroup[$groups])
  }

}
