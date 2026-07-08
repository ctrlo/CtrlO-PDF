use strict;
use warnings;

use Test::More;

use CtrlO::PDF;

subtest 'landscape defaults without optional chrome' => sub {
    my $pdf = CtrlO::PDF->new(
        orientation => 'landscape',
        top_padding => 5,
    );

    is $pdf->width, 842, 'Landscape width uses A4 landscape';
    is $pdf->height, 595, 'Landscape height uses A4 landscape';
    is $pdf->margin_top, 45, 'Top margin falls back to margin plus top padding';
    is $pdf->logo_height, 0, 'No logo means zero logo height';
    is $pdf->logo_width, 0, 'No logo means zero logo width';

    $pdf->add_page;
    like $pdf->content, qr/\A%PDF-/, 'PDF content can be generated without header, footer, or logo';
};

subtest 'text no-op and y position movement' => sub {
    my $pdf = CtrlO::PDF->new;

    $pdf->text(undef);
    is $pdf->page_count, 0, 'Undefined text does not create a page';

    $pdf->add_page;
    $pdf->set_y_position(123.5);
    is $pdf->y_position, 123.5, 'set_y_position accepts numeric values';

    $pdf->move_y_position(-23.5);
    is $pdf->y_position, 100, 'move_y_position adjusts the cursor';

    eval { $pdf->set_y_position('not-a-number') };
    like $@, qr/Invalid y value for set_y_position/, 'set_y_position rejects invalid values';

    eval { $pdf->move_y_position(0) };
    like $@, qr/Invalid y value for move_y_position/, 'move_y_position rejects zero';
};

subtest 'heading and text paginate near the bottom of the page' => sub {
    my $heading_pdf = CtrlO::PDF->new;

    $heading_pdf->add_page;
    $heading_pdf->set_y_position(149);
    $heading_pdf->heading(
        'Late heading',
        size         => 12,
        topmargin    => 5,
        bottommargin => 7,
    );

    is $heading_pdf->page_count, 2, 'Heading creates a new page when too close to the bottom';
    is $heading_pdf->y_position, $heading_pdf->height - $heading_pdf->margin_top - 12, 'Explicit heading margins are applied on the new page';

    my $text_pdf = CtrlO::PDF->new;

    $text_pdf->add_page;
    $text_pdf->set_y_position($text_pdf->margin_bottom + 1);
    $text_pdf->text('A short paragraph at the bottom of the page');

    is $text_pdf->page_count, 2, 'Text creates a new page when there is no room left';
};

subtest 'image placement supports default, left, and right alignment' => sub {
    my $pdf = CtrlO::PDF->new;

    $pdf->image('sample/logo.png');
    is $pdf->page_count, 1, 'Default image placement creates the first page';

    my $after_center = $pdf->y_position;
    $pdf->image('sample/logo.png', alignment => 'left', scaling => 1);
    cmp_ok $pdf->y_position, '<', $after_center, 'Left-aligned image moves the cursor down';

    $pdf->set_y_position(50);
    $pdf->image('sample/logo.png', alignment => 'right', scaling => 1);
    is $pdf->page_count, 2, 'Right-aligned image starts a new page when it does not fit';

    like $pdf->content, qr/\A%PDF-/, 'Image content can be rendered into a PDF';
};

done_testing();
