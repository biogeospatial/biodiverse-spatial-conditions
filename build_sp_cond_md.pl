use 5.016;
use strict;
use warnings;

use rlib '../../lib';

use Biodiverse::BaseData;
use Biodiverse::SpatialConditions;

my $bd = Biodiverse::BaseData->new (
    CELL_SIZES => [1,1],
);
$bd->add_element (                    
    label => 'a:b',
    group => '1:1',
    count => 1,
);
my $lb_ref = $bd->get_labels_ref;
$lb_ref->set_param (CELL_SIZES => [-1,-1]);


my $sp = Biodiverse::SpatialConditions->new(conditions => 1);

my $markdown;
$markdown .= get_preamble();
$markdown .= $sp->get_conditions_metadata_as_markdown;
$markdown .= get_post_amble();

my $version = $Biodiverse::Config::VERSION;
my %sub_names = $sp->get_subs_with_prefix (prefix => 'sp_');
my $sub_list_text = "The available functions in version $version are:\n";
for my $sub_name (sort keys %sub_names) {
    my $anchor = $sub_name;
    #$anchor =~ s/_/-/;
    $sub_list_text .= "  [*$sub_name*](#$sub_name), ";
}
$markdown =~ s/===LIST_OF_FUNCTIONS===/$sub_list_text/;

my $fname = 'spatial_conditions.md';

open(my $fh, '>', $fname) or die "Cannot open $fname";

say {$fh} $markdown;

$fh->close;

#  pandoc saves re-engineering the internal code
my @args = qw /pandoc -f gfm -t markdown -o spatial_conditions.qmd spatial_conditions.md/;
system (@args) == 0
    or die "system @args failed: $?";

sub get_preamble {
    return <<'END_OF_PREAMBLE'
# Functions #

Functions are the easiest way to specify conditions as one does not need to wrestle with variables.  Functions also set metadata to tell the system how to use the spatial index.  The [spatial index](https://biogeospatial.github.io/biodiverse-quick-start/5-data-analysis.html#building-a-spatial-index){.external target="_blank"} saves considerable processing time for large data sets as the system does not need to test many pairs of index blocks to determine which to use.  If you use a function for which an index will produce erroneous results then the system sets a flag to ignore it.  You can also disable it in the settings for a spatial condition.

## Available functions ##

===LIST_OF_FUNCTIONS===

END_OF_PREAMBLE
}

sub get_post_amble {
    return <<'END_OF_POSTAMBLE'
END_OF_POSTAMBLE
}

