use v6.c;

use Test;
use XML::XPath;
use XML::XPath::Expr;
use XML::XPath::Step;

plan 2;

my $x = XML::XPath.new;

is-deeply $x.parse-xpath("/aaa"),
XML::XPath::Expr.new(
    operator => '',
    expression => XML::XPath::Step.new(
        axis     => 'self',
        literal  => 'aaa',
        operator => '/',
    )
);

is-deeply $x.parse-xpath("/aaa/bbb"),
XML::XPath::Expr.new(
    operator => '',
    expression => XML::XPath::Step.new(
        axis       => 'self',
        literal    => 'aaa',
        operator   => '/',
        next       => XML::XPath::Step.new(
            axis     => 'child',
            literal  => 'bbb',
            operator => '/',
        )
    )
);

