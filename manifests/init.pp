class users_sys {
  $users = hiera_array("${module_name}::users",undef)
  $groups = hiera_array("${module_name}::groups",undef)
  $users_settings = hiera_hash("${module_name}::users_settings",undef)
  $groups_settings = hiera_hash("${module_name}::groups_settings",undef)
  $user_defaults = hiera_hash("${module_name}::user_defaults",{ })
  $group_defaults = hiera_hash("${module_name}::group_defaults",{ })


  if is_hash($users_settings) {
    create_resources("@${module_name}::localuser",$users_settings,$user_defaults)
    if is_array($users) {
      $remaining_users = subtract_array($users,keys($users_settings))
      @localuser { $remaining_users: }
    }
  } elsif is_array($users) {
    @localuser { $users: }
  }
  
  if is_hash($groups_settings) {
    create_resources("@${module_name}::localgroup",$groups_settings,$group_defaults)
    if is_array($groups) {
      $remaining_groups = subtract_array($groups,keys($groups_settings))
      @localgroup { $remaining_groups: }
    }
  } elsif is_array($groups) {
    @localgroup { $groups: }
  }

  if $users {
    realize(Localuser[$users])
  }
  if $groups {
    realize(Localgroup[$groups])
  }

}
