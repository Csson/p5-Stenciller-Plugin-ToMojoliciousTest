use 5.10.0;
use strict;
use warnings;

package Stenciller::Plugin::ToMojoliciousTest;

our $VERSION = '0.0104';
# ABSTRACT: Create Mojolicious tests from text files parsed with Stenciller
# AUTHORITY

use Moose;
use Types::Path::Tiny qw/Path/;
with 'Stenciller::Transformer';

has template => (
    is => 'ro',
    isa => Path,
    required => 1,
    coerce => 1,
);

sub transform {
    my $self = shift;
    my $transform_args = shift;

    my @out = $self->init_out($self->stenciller, $transform_args);

    my @stencils = ();

    STENCIL:
    for my $i (0 .. $self->stenciller->max_stencil_index) {

        next STENCIL if $self->should_skip_stencil_by_index($i, $transform_args);

        my $stencil = $self->stenciller->get_stencil($i);
        next STENCIL if $self->should_skip_stencil($stencil, $transform_args);

        push @stencils => $stencil;
    }

    foreach my $stencil (@stencils) {

        my $expected_var = sprintf '$expected_%s', $stencil->stencil_name;

        push @out => sprintf "# test from line %s in %s", $stencil->line_number, $self->stenciller->filepath->basename;

        #warn "-------\n" . $stencil->all_output . "\n-----------<<";
        push @out => sprintf 'my %s = qq{%s};', $expected_var, join ("\n" => $stencil->all_output);

        push @out => sprintf q{get '/%s' => '%s';}, $stencil->stencil_name, $stencil->stencil_name;

        my $test_comment = sprintf q{Matched trimmed content in %s, line %s} => $self->stenciller->filepath->basename, $stencil->line_number;
        push @out => sprintf q{$test->get_ok('/%s')->status_is(200)->trimmed_content_is(%s, '%s');} => $stencil->stencil_name, $expected_var, $test_comment;

    }

    push @out => 'done_testing();';
    push @out => '__DATA__';

    foreach my $stencil (@stencils) {
        push @out => sprintf '@@ %s.html.ep' => $stencil->stencil_name;
        push @out => $stencil->all_input;
    }

    my $content = join "\n\n" => '', @out, '';
    $content =~s{\v{2,}}{\n\n}g;

    my $template = $self->template->slurp_utf8;
    return $template.$content;
}

1;


__END__

=pod

=head1 SYNOPSIS

    use Stenciller;

    my $contents = Stenciller->new(filepath => 'path/to/filetoparse.stencil')->transform(
        plugin_name => 'ToMojoliciousTest',
        transform_args => {
            require_in_extra => {
                key => 'is_test',
                value => 1,
                default => 1
            },
        },
        constructor_args => {
            template => 'path/to/template.test',
        },
    );

=head1 DESCRIPTION

Stenciller::Plugin::ToMojoliciousTest is a L<Stenciller> plugin that transforms stencils to Mojolicious tests.

If you build your distribution with L<Dist::Zilla> the L<Dist::Zilla::Plugin::Stenciller::MojoliciousTests> plugin is an easy way to use this class.

If the text file looks like this:

    == stencil ==

    --input--
        %= link_to 'Example', 'http://www.example.com/'
        %= form_for '01_test_1'
    --end input--

    --output--
        <a href="http://www.example.com/">Example</a>
        <form action="/01_test_1"></form>
    --end output--

And the template file like this:

    use 5.10.1;
    use strict;
    use warnings;
    use Test::More;
    use Test::Warnings;
    use Test::Mojo::Trim;
    use Mojolicious::Lite;

    use if $ENV{'AUTHOR_TESTING'}, 'Test::Warnings';

    my $test = Test::Mojo::Trim->new;


Then C<$contents> will contain this:

        use 5.10.1;
        use strict;
        use warnings;
        use Test::More;
        use Test::Warnings;
        use Test::Mojo::Trim;
        use Mojolicious::Lite;

        use if $ENV{'AUTHOR_TESTING'}, 'Test::Warnings';

        my $test = Test::Mojo::Trim->new;


        # test from line 1 in 01-test.stencil

        my $expected_01_test_1 = qq{    <a href="http://www.example.com/">Example</a>
    <form action="/01_test_1"></form>};

        get '/01_test_1' => '01_test_1';

        $test->get_ok('/01_test_1')->status_is(200)->trimmed_content_is($expected_01_test_1, 'Matched trimmed content in 01-test.stencil, line 1');

        done_testing();

        __DATA__

        @@ 01_test_1.html.ep

            %= link_to 'Example', 'http://www.example.com/'

            %= form_for '01_test_1'

Do note that the generated tests currently are hardcoded to use C<trimmed_content_is> from C<Test::Mojo::Trim>. This might change in the future.

=head1 SEE ALSO

=for :list
* L<Stenciller>
* L<Dist::Zilla::Plugin::Stenciller::ToMojoliciousTests>

=cut
