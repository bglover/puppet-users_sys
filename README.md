#users_sys

This is a heavy modification of this [module.](https://github.com/francispereira/puppet-generic) It
seeks to manage users, groups and their local and remote access. All my classes are 100% hiera
defined as all my manifests are done in modules. Its called users_sys as opposed to
users_ftp or users_smb, etc. 

Also, I like JSON and Im keeping a firm code/data split, so expect configurations purely as JSON.
## class users_sys

Assuming your site.pp consists of hiera_include('classes'), how to use:
{
  "classes" : [
    "users_sys"
  ]
}

Including this module will allow the following hiera objects to be used, but none are required:
 ```javascript
{
  "users_sys::users" : [],
  "users_sys::groups" : [],
  "users_sys::user_defaults" : { localuser_defaults_here },
  "users_sys::group_defaults" : { localgroup_defaults_here },
  "users_sys::users_settings" : { localuser_definition_here },
  "users_sys::groups_settings" : { localgroup_definition_here }
}
```
Users and groups are generated across the hierachy. Pretty sure the lowest defined for a host is the
one that will get used. Defaults are just a hash of values to be set as the defaults for all items
in users/groups_settings. Im using create_resouces() for this so defaults are hash of default
localuser and localgroup attributes, and settings are hashes of hashes of localuser and localgroup attributes. 

So to make all your users have a comment it would be:
"users_sys::user_defaults" : { "comment" : "lulzers", "shell" : "/sbin/lulzshell" } 

while if you didnt like little bobby you could set: 
"users_sys:users_settings" : { "littlebobby" : { "group" : "shadowbanned" } }

```javascript
{
  "users_sys::user_defaults" : {
    "comment" : "default comment"
  }
}
```
#### Passwords
Passwords are set via the hash and ONLY if no password is set. My suggestion is to set both the password and the expiry (to a date in the past) in user_defaults, assuming that you use SSH keys for access provides a simple vaguely secure method of creating initial users passwords. If you have a problem storing a default password hash in puppet, I suggest looking at the hiera_gpg backend.

I will probably expand this in the future to be fancier as I fit some better security needs. 

## defined type localuser
```javascript
{
  "username..." : {
    "comment" : "",
    "expiry" : "", # 2010-02-19, set in past to force pw change 
    "uid" : "",
    "gid" : "",
    "groups" : "",
    "shell" : "",
    "system" : "", # whether user has a system ID
    "password" : "", # Password Hash
    "ssh_authorized_key" : "",
    "ssh_authorized_key_type" : "",
    "ssh_authorized_key_options" : "" #  Multiple values should be specified as an array
  }
}
```

## defined type localgroup
```javascript
{
  "groupname..." : {
    "ensure" : "present",
    "gid" : ""
  }
}
```
## custom function subtract_array
Simple, yeah, I know. 
```ruby
module Puppet::Parser::Functions
  newfunction(:subtract_array, :type => :rvalue) do |args|
    args[0] - args[1]
  end
end
```


