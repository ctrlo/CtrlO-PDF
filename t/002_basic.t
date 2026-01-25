use Test::More tests => 2;
use strict;
use warnings;
use File::Temp qw(tempdir);
use File::Spec::Functions qw(catfile);
use File::Compare qw(compare);

use CtrlO::PDF;

# TODO: Add image tests of valid and invalid image files.

my $pdf = CtrlO::PDF->new(
#  logo        => "logo.png", # XXX Where to put an image for testing?
  footer      => "My PDF document footer",
);

# Add a page
$pdf->add_page;

# Add headings
$pdf->heading('This is the main heading');
$pdf->heading('This is a sub-heading', size => 12);

# Add paragraph text
$pdf->text("Foobar");

my $content = $pdf->content;
ok($content, "Some PDF content produced");

# For debugging one can set CLEANUP to 0 and enable the diag to see
# the name of the temporary folder.
my $dir = tempdir( CLEANUP => 1 );
# diag $dir;

my $file = catfile($dir, 'out.pdf');

open my $out, '>', $file;
binmode $out;
print $out $content;
close $out;

is(compare($file, 'sample/002_basic.pdf'), 0, 'File is as expected');
