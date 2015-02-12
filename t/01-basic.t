use 5.14.0;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Test::Differences;
use Stenciller;
use if $ENV{'AUTHOR_TESTING'}, 'Test::Warnings';

BEGIN {
    use_ok 'Stenciller::Plugin::ToMojoliciousTest';
}

my $stenciller = Stenciller->new(filepath => 't/corpus/01-test.stencil');

is $stenciller->count_stencils, 1, 'Found stencils';

my $transformed = $stenciller->transform(
									plugin_name => 'ToMojoliciousTest',
									constructor_args => {
										template => 't/corpus/01-test.template',
									},
								);

eq_or_diff $transformed, result(), 'Mojolicious test created';

done_testing;

sub result {
    return qq{

Header
lines

If you write this:

    <%= badge '3' %>

It becomes this:

    <span class="badge">3</span>

};
}
