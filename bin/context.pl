#! /bin/perl
# My first original perl program! - DW
#
$numargs = @ARGV;
if ( $numargs < 2)
{ die "Purpose: grep showing 5 lines of context before and after\nUsage: context string file1 ...\nExample: context search file1\n" }

$searchstr = shift(@ARGV);
#print @ARGV,"\n";
#print "Search:",$searchstr,"\n";

@last5=("");
$found = -5;
$n = 0;
while (<>) { 
#print$_;

$n = $n + 1;
push(@last5,$_);

if ( $n > 5 )
 { $tmp = shift(@last5); }

if ( $n < $found )
 { print $_; }
else { $found = -5;
       if ( /$searchstr/ ) 
        { $s = $n - 5;
          if( $s < 1) { $s = 1; }
          print ("\nline ",$s," to line ",$n+5," -----------------------------------------","\n");
          print @last5;
          $found = $n + 6
        }
     }


}


