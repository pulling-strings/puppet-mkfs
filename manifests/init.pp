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
class mkfs($device='',$type='ext4', $dest='') {

  exec{'create fs':
    command => "mkfs.${type} ${device} -F",
    user    => 'root',
    path    => ['/usr/bin','/sbin'],
    unless  => "/usr/bin/file -s ${device} | /bin/grep ${type}",
  } ~>

  exec{'mount all':
    command     => 'mount -a',
    user        => 'root',
    path        => ['/usr/bin','/bin'],
    refreshonly => true,
    require     => Mount[$dest]
  }

  file{$dest:
    ensure => directory,
  } ->

  mount { $dest:
    ensure    => 'present',
    device    => $device,
    fstype    => $type,
    options   => 'defaults',
    atboot    => 'true',
    remounts  => false
  }
}
