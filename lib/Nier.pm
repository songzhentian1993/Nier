package Nier;

use strict;
use warnings;
use Nier::FileCleaner;
use Nier::CommentExtractor;
use Nier::LicenseMatcher;
use Nier::SentenceExtractor;
use Nier::SentenceFilter;
use Nier::SentenceTokenizer;

our $VERSION = '1.3.2';

sub process_file {
    my ($input_file, $create_intermediary_files, $verbose) = @_;

    print STDERR "analysing file [$input_file]\n" if $verbose;

    if (not (-f $input_file)) {
        print STDERR "file [$input_file] is not a file\n";
        return;
    }

    my %common_parameters = (verbose => $verbose);

    my %parameters_step0 = (%common_parameters, input_file => $input_file);
    my $cleaned_input_file = Nier::FileCleaner->new(%parameters_step0)->execute;
    
    my %parameters_step1 = (%common_parameters, input_file => $cleaned_input_file);
    my $comments = Nier::CommentExtractor->new(%parameters_step1)->execute();

    my %parameters_step2 = (%common_parameters, comments => $comments);
    my $sentences_ref = Nier::SentenceExtractor->new(%parameters_step2)->execute();

    my %parameters_step3 = (%common_parameters, sentences => $sentences_ref);
    my ($good_sentences_ref, $bad_sentences_ref) = Nier::SentenceFilter->new(%parameters_step3)->execute();

    my %parameters_step4 = (%common_parameters, sentences => $good_sentences_ref);
    my $license_tokens_ref = Nier::SentenceTokenizer->new(%parameters_step4)->execute();

    my %parameters_step5 = (%common_parameters, license_tokens => $license_tokens_ref);
    my $license_result = Nier::LicenseMatcher->new(%parameters_step5)->execute();

    if ($create_intermediary_files) {
        create_intermediary_file($input_file, 'comments',  $comments);
        create_intermediary_file($input_file, 'sentences', join("\n", @$sentences_ref));
        create_intermediary_file($input_file, 'goodsent',  join("\n", @$good_sentences_ref));
        create_intermediary_file($input_file, 'badsent',   join("\n", @$bad_sentences_ref));
        create_intermediary_file($input_file, 'senttok',   join("\n", @$license_tokens_ref));
        create_intermediary_file($input_file, 'license',   $license_result);
    }

    return $license_result;
}

sub create_intermediary_file {
    my ($input_file, $output_extension, $content) = @_;

    my $output_file = "$input_file.$output_extension";
    open my $output_fh, '>', $output_file or die "can't create output file [$output_file]: $!";
    print $output_fh $content;
    close $output_fh;
}

1;

__END__


