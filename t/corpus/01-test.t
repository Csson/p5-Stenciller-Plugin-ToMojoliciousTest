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