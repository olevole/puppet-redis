# alternative redis name sets via $redisname

define redis-new::server( $ensure=present,
	$version="latest",
	$redisname="redis",
	$bind="0.0.0.0",
	$port=6379,
	$requirepass="",
	$tcpkeepalive="0",
	$loglevel="warning",
	$syslog="yes",
	$maxclients="",
	$maxmemory="",
	$maxmemory_policy="",
	$maxmemory_samples="",
	$masterip="",
	$masterport=6379,
	$masterauth="",
	$notify_restart=false,
	$timeout=300,
	$logfile="/var/log/redis/redis.log",
	$appendonly="no",
	$aof=true,
	$aof_auto_rewrite_percentage=100,
	$aof_auto_rewrite_min_size="64mb" ) {

	if $redisname == "redis" {
		# let's default values
		$dbfilename="dump.rdb"
		$appendfilename="appendonly.aof"
		$pidfile="/var/run/redis/redis.pid"
	} else {
		$dbfilename="$redisname-dump.rdb"
		$appendfilename="appendonly-$redisname.aof"
		$pidfile="/var/run/redis/redis-$redisname.pid"
	}

	if $logfile == "/dev/null" {
		$redis_logfile="/dev/null"
	} else {
		$redis_logfile="/var/log/redis/redis-$redisname.log"
	}

	case $operatingsystem {
		centos, redhat, debian, ubuntu: {
			$redisconfig="/etc/redis/$redisname.conf"
			if $redisname == "redis" {
				$servicename="redis-server"
			} else {
				$servicename="redis-$redisname"
			}
			$dir="/var/lib/redis"
			Class ["redis-new::install"] -> File["$redisconfig"] -> Service["$servicename"]
			}
		freebsd: {
			if $redisname == "redis" {
				# let's default values
				$redisconfig="/usr/local/etc/redis.conf"
				
			} else {
				$redisconfig="/usr/local/etc/redis-$redisname.conf"
			}
			if $redisname == "redis" {
				$servicename="redis"
			} else {
				$servicename="redis-$redisname"
			}
			$dir="/var/db/redis"
			# rc.d script for FreeBSD
			if $redisname != "redis" {
					file { "/usr/local/etc/rc.d/redis-$redisname":
					ensure  => present,
					content => template("redis-new/freebsd.rc.d.erb"),
					mode => '0555',
					}
				}
			}
	}

	# Ubuntu with upstart
	if $operatingsystem == "ubuntu" and $redisname != "redis" {
		file { "/etc/init/redis-$redisname.conf":
			ensure  => present,
			content => template("redis-new/ubuntu.init.erb"),
			mode => '0644',
		}
	}

	file { "$redisconfig":
		notify  => $notify_restart ? {
			true    => Exec["$redisname-server_restart"],
			default => undef,
		},
		mode => '0444',
		ensure  => present,
		content => template("redis-new/redis.conf.erb"),
	}

	exec {"$redisname-server_restart":
		command     => "service $servicename restart",
		refreshonly => true,
	}

	service {"$servicename":
		enable     => true,
		hasrestart => true,
		hasstatus  => true,
	}
}
