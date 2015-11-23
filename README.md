# NAME

Stenciller::Plugin::ToMojoliciousTest - Create Mojolicious tests from text files parsed with Stenciller

![Requires Perl 5.14+](https://img.shields.io/badge/perl-5.14+-brightgreen.svg) [![Travis status](https://api.travis-ci.org//.svg?branch=master)](https://travis-ci.org//)

# VERSION

Version 0.0001, released 2015-11-23.

# SYNOPSIS

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

# DESCRIPTION

Stenciller::Plugin::ToMojoliciousTest is a [Stenciller](https://metacpan.org/pod/Stenciller) plugin that transforms stencils to Mojolicious tests.

If you build your distribution with [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla) the [Dist::Zilla::Plugin::Stenciller::ToMojoliciousTests](https://metacpan.org/pod/Dist::Zilla::Plugin::Stenciller::ToMojoliciousTests) plugin is recommended.

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

Then `$contents` will contain this:

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

Do note that the generated tests currently are hardcoded to use `trimmed_content_is` from `Test::Mojo::Trim`. This might change in the future.

# SEE ALSO

- [Stenciller](https://metacpan.org/pod/Stenciller)
- [Dist::Zilla::Plugin::Stenciller::ToMojoliciousTests](https://metacpan.org/pod/Dist::Zilla::Plugin::Stenciller::ToMojoliciousTests)

# SOURCE

[https://github.com/Csson/p5-Stenciller-Plugin-ToMojoliciousTest](https://github.com/Csson/p5-Stenciller-Plugin-ToMojoliciousTest)

# HOMEPAGE

[https://metacpan.org/release/Stenciller-Plugin-ToMojoliciousTest](https://metacpan.org/release/Stenciller-Plugin-ToMojoliciousTest)

# AUTHOR

Erik Carlsson <info@code301.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Erik Carlsson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
