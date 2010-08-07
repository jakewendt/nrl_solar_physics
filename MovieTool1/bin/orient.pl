#!/usr/bin/perl
#	#!/usr/bin/perl -w	#	don't use -w for final bc get uninitialized localtime message


if ( $ARGV[0] eq '' ) {
	my ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = localtime;
	$DATE = sprintf ( "%4d%02d%02d%02d%02d%02d", $year+1900, $mon+1, $day, $hour, $min, $sec );
} else {
	$DATE = $ARGV[0];
}

#print "$DATE\n";
#http://sohowww.nascom.nasa.gov/data/ancillary/attitude/roll/nominal_roll_attitude.dat

use IO::Socket;
$sock = new IO::Socket::INET (PeerAddr => 'sohowww.nascom.nasa.gov',
                            PeerPort => 'http(80)')
    || die "couldn't create socket: $@";

$sock->autoflush(1);

#   Macs should use \015\012\015\012 instead of \n\n ???
$sock->print("GET /data/ancillary/attitude/roll/nominal_roll_attitude.dat\n\n");

#open IN, '/net/cronus/opt/local/idl_nrl_lib/lasco/data//attitude/roll/nominal_roll_attitude.dat';
$rotation=0;
while (<$sock>) { 
	if ( ! /^#/ ) { 
		($yyyy, $mm, $dd, $h, $m, $s, $ROT ) = /(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d+)\s+(\d+)/;
		$DateRead = sprintf ( "%4d%02d%02d%02d%02d%02d", $yyyy, $mm, $dd, $h, $m, $s );
#		print $_ ;
#		print "$DateRead\n";
#		print "$ROT\n";
		if ( $DateRead > $DATE ) {
			last;
		} else {
			$rotation = $ROT;
		}
#		print $_ ;
	}
}
#close IN;

print "$rotation\n";


