use IO::CaptureOutput qw/capture_exec/;

@command1 = ("comments", "-c1", "main.cpp");

#($stdout, $error, $success, $status) = capture_exec( @command );
#print "command1--------";
#print "$stdout\n";
#print "$error\n";
#print "$success\n";
#print "$status\n";

@command2 = ("head", "-400", "main.cpp");
($stdout, $error, $success, $status) = capture_exec( @command );
print "command2--------";
print "$stdout\n";
print "$error\n";
print "$success\n";
print "$status\n";


$output_file = "main.cpp.testcomments";
open $output_fh, '>', $output_file or die "can't create output file [$output_file]: $!";
print $output_fh $stdout;
close $output_fh;