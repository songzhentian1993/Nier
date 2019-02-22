package Nier::CommentExtractor;

use strict;
use warnings;
use IPC::Open3 'open3';
use Symbol 'gensym';
use IO::CaptureOutput qw/capture_exec/;

sub new {
    my ($class, %args) = @_;

    my $self = bless({}, $class);

    die "parameter 'input_file' is mandatory" unless exists $args{input_file};

    $self->{verbose} = ($args{verbose} // 0) == 1;
    $self->{input_file} = $args{input_file};

    return $self;
}

sub execute {
    my ($self) = @_;

    my @command = $self->determine_comments_command();
    my $comments = execute_command(@command);
    if ($command[0] =~ /^comments/ && length($comments) == 0) {
        @command = create_head_cmd($self->{input_file}, 700);
        $comments = execute_command(@command);
    }

    return $comments;
}

sub determine_comments_command {
    my ($self) = @_;

    my $input_file = $self->{input_file};

    if ($input_file =~ /\.([^\.]+)$/) {
        my $ext = $1;
        if ($ext =~ /^(pl|pm|py)$/) {
            return create_head_cmd($input_file, 400);
        } elsif ($ext =~ /^(jl|el)$/) {
            return create_head_cmd($input_file, 400);
        } elsif ($ext =~ /^(java|c|cpp|h|cxx|c\+\+|cc)$/) {
            my $comments_binary = 'comments';
            if (`which $comments_binary` ne '') {
                return ($comments_binary, "-c1", $input_file);
            } else {
                return create_head_cmd($input_file, 400);
            }
        } else {
            return create_head_cmd($input_file, 700);
        }
    } else {
        return create_head_cmd($input_file, 700);
    }
}

sub create_head_cmd {
    my ($input_file, $count_lines) = @_;

    return ("head",  "-$count_lines",  $input_file);
}

sub execute_command {
    my ($self, @command) = @_;

    die "command (@command) seems to be missing parameters" unless (scalar(@command) > 1);
	
	if ($command[0] == "head") {
	    my ($stdout, $error, $success, $status) = capture_exec( @command );

		my $commandSt = join(' ', @command);
		die "execution of program [$commandSt] failed: status [$status], error [$error]" if ($status != 0);

		return $stdout;
	}
	
	if ($command[0] == "comments") {
		system(@command);
		open my $fh, $self->{input_file}."comments" or die "can't open file [$self->{input_file}]: $!";
		
		while (my $line = <$fh>) {
			chomp $line;
			my $result .= $line;
		}
		
		close $fh;
		return $result;
	}


}

1;

__END__


