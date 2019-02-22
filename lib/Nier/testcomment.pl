use IO::CaptureOutput qw/capture_exec/;

@command = ("comments", "-c1", "main.cpp");

($stdout, $error, $success, $status) = capture_exec( @command );

$output_file = "main.cpp.testcomments";
open $output_fh, '>', $output_file or die "can't create output file [$output_file]: $!";
print $output_fh $stdout;
close $output_fh;