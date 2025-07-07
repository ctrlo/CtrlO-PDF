use strict;
use warnings;

use Test::More;

use CtrlO::PDF;

subtest 'Normal-sized table'                      => \&test_normality;
subtest 'Table straddling a page boundary'        => \&test_page_boundary;
done_testing();

# We can produce a table without any weirdness.

sub test_normality {
    my $pdf = CtrlO::PDF->new;

    ok $pdf->is_new_page, 'Nothing on the page yet';
    my $starting_y_position = $pdf->y_position;
    $pdf->table(data => [
        ['Country', 'Capital City'],
        ['France',  'Paris'],
        ['Spain',   'Madrid'],
        ['Andorra', 'Also Andorra lol'],
    ]);
    ok $pdf->y_position < $starting_y_position, 'We say we did something';
}

# A table can wrap over a page.

sub test_page_boundary {
    my $pdf = CtrlO::PDF->new(
        header => 'Print this at the top',
        footer => 'Print this at the bottom'
    );
    is $pdf->pdf->page_count, 0, 'No pages at all at first';
    $pdf->table(data => [
        ['Number', 'Fizzbuzz'],
        map {
            [$_ , ucfirst( ( $_ % 3 ? '' : 'fizz' ) . ( $_ % 5 ? '' : 'buzz' ) )],
        } 1..40
    ]);
    is $pdf->pdf->page_count, 2, 'Our table spanned two pages';
}
