package Nier::FileCleaner;

use strict;
use warnings;
use IPC::Open3 'open3';
use Symbol 'gensym';

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

    my $input_file = $self->{input_file};
        
    my $original = $input_file;

    $input_file =~ s/'/\\'/g;
    $input_file =~ s/\$/\\\$/g;
    $input_file =~ s/;/\\;/g;
    $input_file =~ s/ /\\ /g;

    print "Starting: $original;\n" if ($self->{verbose});

    return $input_file;
}

1;

__END__

