# logfile can be "/dev/null"

class redis-new::install($ensure = present, $version="latest", $overcommit=1 ){

	if $ensure == "absent" {
		$myversion="absent"
	} else {
		$myversion=$version
	}

	case $operatingsystem {
		centos, redhat: { }
		freebsd: {
			$packages = [ "databases/redis" ]
		}
		debian, ubuntu: {
			$packages = [ "redis-tools", "redis-server" ]
			sysctl::conf { "vm.overcommit_memory": value => $overcommit }
		}
		default: {
			fail("Unrecognized operating system")
			}
	}

	package { $packages:
		ensure  => $myversion,
	}
}
