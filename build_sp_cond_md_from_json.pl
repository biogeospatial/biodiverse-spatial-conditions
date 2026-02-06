use 5.016;
use strict;
use warnings;
use JSON;
use Carp qw /croak/;
use experimental qw /refaliasing declared_refs/;

my $json_file = $ARGV[0] // 'spatial_conditions.json';

open my $json_fh, $json_file or die $!;
my $json = do {local $/ = undef; <$json_fh>};
$json_fh->close;

my $data = decode_json ($json);

my $markdown;
$markdown .= get_preamble();
$markdown .= get_conditions_metadata_as_markdown($data);


my $fname = 'spatial_conditions.qmd';

open(my $ofh, '>', $fname) or die "Cannot open $fname";

say {$ofh} $markdown;

$ofh->close;

sub get_conditions_metadata_as_markdown {
    my ($data) = @_;
    my $version = $data->{version};

    \my %subs = $data->{conditions};
    my @sub_names = sort keys %subs;
    my $sub_list_text = "The available functions in version $version are:\n";
    $sub_list_text .= join "\n", map {"[*$_*](#$_), "} @sub_names;
    $sub_list_text =~ s/, \n$/./m;
    $sub_list_text .= "\n\n";

    my $md = $sub_list_text;

    foreach my $sub_name (@sub_names) {
        say $sub_name;
        my $metadata = $subs{$sub_name};
        #say join ' ', sort keys %$metadata;
        my @md_this_sub;
        push @md_this_sub, "### $sub_name";
        push @md_this_sub, $metadata->{description};

        my $required_args = $metadata->{required_args} // [];
        my $arg_string = join ', ', map {"`$_`"} sort @$required_args;
        if (!scalar @$required_args) {
            $arg_string = '*none*';
        }
        push @md_this_sub, "**Required args:**  $arg_string";

        my $optional_args = $metadata->{optional_args} // [];
        $arg_string = join ', ', map {"`$_`"} sort @$optional_args;
        if (!scalar @$optional_args) {
            $arg_string = '*none*';
        }
        push @md_this_sub, "**Optional args:**  $arg_string";

        my $example = $metadata->{example};
        my @ex = split "\n", $example;
        croak "$sub_name has no example" if !$example || $example eq 'no_example';

        push @md_this_sub, "**Example:**\n```perl\n$example\n```";

        $md .= join "\n\n", @md_this_sub;
        $md .= "\n\n";
    }


    $md;
}

sub get_preamble {
    return <<'END_OF_PREAMBLE'
# Functions

Functions are the easiest way to specify conditions as one does not need to wrestle with variables.

Functions also set metadata to tell the system how to use the spatial index.
The [spatial index](https://biogeospatial.github.io/biodiverse-quick-start/5-data-analysis.html#building-a-spatial-index){.external target="_blank"}
saves considerable processing time for large data sets as the system does
not need to test many pairs of index blocks to determine which to use.  If you use a function for which an
index will produce erroneous results then the system sets a flag to ignore it.
You can also disable it in the settings for a spatial condition.

## Available functions

END_OF_PREAMBLE
}

