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
define mkfs::device($type='ext4', $dest='') {

  exec{"create fs $name":
    command => "mkfs.${type} ${name} -F",
    user    => 'root',
    path    => ['/usr/bin','/sbin'],
    timeout => 0,
    unless  => "/usr/bin/file -s ${name} | /bin/grep ${type}",
  } ~>

  exec{"mount all $name":
    command     => 'mount -a',
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
