use Test::More tests => 2;
use strict;
use warnings;
use Carp 'verbose'; local $SIG{__DIE__} = sub { Carp::confess(@_) };

use CtrlO::PDF;

# The following tests don't actually check the output of a PDF, but check that
# it can be produced. TODO: Add image tests of valid and invalid image files.

my $pdf = CtrlO::PDF->new(
  logo        => "logo.png", # XXX Where to put an image for testing?
  footer      => "test PDF document footer",
);

# Add a page
$pdf->add_page;

# Add headings
$pdf->heading('This is the main heading');
$pdf->heading('This is a sub-heading', size => 12);
# Add paragraph text
$pdf->text("Foobar");
$pdf->text("Bluebar", 'color' => 'blue' );
$pdf->text("Redbar", 'color' => 'red' );
$pdf->text("Newbar", 'color' => 'yellow' );
$pdf->text("accented vowels, etc.: á é í ó ú ñ  Á É Í Ó Ú Ñ");
use utf8;
$pdf->text("accents (use utf8;): á é í ó ú ñ  Á É Í Ó Ú Ñ");
no utf8;
$pdf->text("accents (no utf8;): á é í ó ú ñ  Á É Í Ó Ú Ñ");
$pdf->text("Foobar again");
$pdf->image( 'logo.png' , 'scaling' => 1 );

# Add a table
use utf8;
my $data =[
    ['Fruit', 'Quantity'], # Table header
    ['Apples', 120],
    ['Pears', 90],
    ['"use utf8": accents: á é í ó...', 30],
];
 
my $hdr_props = {
    repeat     => 1,
    justify    => 'center',
    font_size  => 8,
};
 
$pdf->table(
    data => $data,
    header_props => $hdr_props,
);
$pdf->image( 'logo.png' , 'scaling' => 0.3   );

no utf8;
$data =[
    ['Fruit', 'Quantity'], # Table header
    ['Apples', 120],
    ['Pears', 90],
    ['"no utf8": accents bad: á é í ó...', 30],
];
 
$hdr_props = {
    repeat     => 2,
    justify    => 'left',
    font_size  => 14,
};
 
$pdf->table(
    data => $data,
    header_props => $hdr_props,
);

my $file = $pdf->content; open (my $fh, ">", 'CtrlO_pdf.pdf'); binmode $fh; print $fh $file; close $fh;  #   exit;

ok($file, "Some PDF content produced in the file 'CtrlO_pdf.pdf'");
ok($pdf->content , "\$pdf->content can be called twice");
exit;