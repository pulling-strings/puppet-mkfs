# == Class: mkfs
#
# Basic file system creation and mounting (no partitioning)
#
# === Examples
# # dest should already be in place
# class{'partition':
#    device => '/dev/sdb',
#    dest => '/mnt/drive/'
# }
# === Authors
#
# Ronen Narkis <narkisr@gmail.com>
#
# === Copyright
#
# Copyright 2013 Ronen Narkis, unless otherwise noted.
#
define mkfs::device(
  $type='ext4',
  $dest='',
  $user = 'root',
  $group = 'root',
  $lazy=true) {

  if($lazy){
    $mkfs = "mkfs.${type} ${name} -F -E lazy_itable_init"
  } else {
    $mkfs = "mkfs.${type} ${name} -F"
  }

  exec{"create fs ${name}":
    command => $mkfs,
    user    => 'root',
    path    => ['/usr/bin','/sbin'],
    timeout => 0,
    unless  => "/usr/bin/file -s ${name} | /bin/grep ${type}",
  } ~>

  exec{"mount ${name}":
    command     => "mount ${name} ${dest}",
    user        => 'root',
    path        => ['/usr/bin','/bin'],
    refreshonly => true,
    require     => Mount[$dest]
  } ~>

  exec{"set user ${user} on ${dest}":
    command     => "chown ${user} ${dest} -R",
    user        => 'root',
    path        => ['/usr/bin','/bin'],
    refreshonly => true,
    require     => Mount[$dest]
  } ~>

  exec{"set group ${group} on ${dest}":
    command     => "chgrp ${group} ${dest} -R",
    user        => 'root',
    path        => ['/usr/bin','/bin'],
    refreshonly => true,
    require     => Mount[$dest]
  }

  mount { $dest:
    ensure   => 'present',
    device   => $name,
    fstype   => $type,
    options  => 'defaults',
    atboot   => 'true',
    remounts => false,
    require  => File[$dest]
  }


}
