#

define redis-new::conf($ensure = present, $value=" ", $section="") {
	File {
		owner => 'redis',
		mode  => '0540'
	}
}
