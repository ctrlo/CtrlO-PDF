use strict;
use warnings;

use Test::More;

use CtrlO::PDF;

subtest 'Normal-sized table'                      => \&test_normality;
subtest 'Table straddling a page boundary'        => \&test_page_boundary;
subtest 'Table header straddling a page boundary' => \&test_header_page_boundary;
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

# The table *header* can wrap over a page boundary as well.

sub test_header_page_boundary {
    my $pdf = CtrlO::PDF->new(
        header => "Stuff at the top",
        footer => "Stuff at the bottom",
    );
    $pdf->page;
    $pdf->set_y_position(120);
    # There isn't room on the page, with the standard font size, for all entries in Borges'
    # classification.
    $pdf->table(data => [
        [
            'Name', 'Belongs to the Emperor?',
            'Embalmed / Trained / Suckling pig / Mermaid / Siren / Fabled / Stray dog?',
            'Included in this classification?',
            'Trembles as if they were mad?', 'Innumerable?',
            'Drawn with a very fine camel hair brush?',
            'etc.?',
        ],
        [
            'Soldier', 'Some of them do', 'Trained, eventually fabled',
            'No', 'Hard to tell',
            'Rarely', 'No', 'etc.'
        ],
        [
            'Chimera', 'No', 'Sort-of like a mermaid, fabled?',
            'Which classification anyway?',
            'Parts might', 'No', 'No', 'etc.'
        ]
    ]);
    is $pdf->pdf->page_count, 2, 'Our table spanned two pages';
}
