package Nier::SentenceFilter;

use strict;
use warnings;
use File::Basename 'dirname';
use File::Spec::Functions 'catfile';

sub new {
    my ($class, %args) = @_;

    my $self = bless({}, $class);

    die "parameter 'sentences' is mandatory" unless exists $args{sentences};

    my $path = dirname(__FILE__);

    $self->{verbose} = ($args{verbose} // 0) == 1;
    $self->{sentences} = $args{sentences};
    $self->{critical_words} = read_critical_words(catfile($path, 'criticalwords.dict'));

    return $self;
}

sub execute {
    my ($self) = @_;

    my $good_sentences = [];
    my $bad_sentences = [];

    foreach my $sentence (@{$self->{sentences}}) {
        chomp $sentence;
        next unless $sentence;
        my $array_ref = $self->contains_critical_word($sentence) ? $good_sentences : $bad_sentences;
        push @$array_ref, $sentence;
    }

    return ($good_sentences, $bad_sentences);
}

sub read_critical_words {
    my ($file) = @_;
    my @critical_words = ();

    open my $fh, '<', $file or die "can't open file [$file]: $!";

    while (my $line = <$fh>) {
        chomp $line;
        next if $line =~ /^\#/;
        $line =~ s/\#.*$//; # remove everything to the end of line
        push @critical_words, qr/\b$line\b/i;
    }

    close $fh;

    return \@critical_words;
}

sub contains_critical_word {
    my ($self, $sentence) = @_;

    my $check = 0;
    foreach my $critical_word (@{$self->{critical_words}}) {
        if ($sentence =~ $critical_word) {
            $check = 1;
            last;
        }
    }

    return $check;
}

1;

__END__

