use v6.c;

use Test;
use XML::XPath;
use XML::XPath::Expr;
use XML::XPath::Step;

plan 3;

my $x = XML::XPath.new;
my $expression;

$expression = "/aaa";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => '',
    operand  => XML::XPath::Step.new(
        axis     => 'self',
        literal  => 'aaa',
    )
), $expression;

$expression = "/aaa/bbb";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => '',
    operand  => XML::XPath::Step.new(
        axis     => 'self',
        literal  => 'aaa',
        next     => XML::XPath::Step.new(
            axis     => 'child',
            literal  => 'bbb',
        )
    )
), $expression;

$expression = "/aaa/bbb/ccc";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => '',
    operand  => XML::XPath::Step.new(
        axis       => 'self',
        literal    => 'aaa',
        next       => XML::XPath::Step.new(
            axis     => 'child',
            literal  => 'bbb',
            next     => XML::XPath::Step.new(
                axis     => 'child',
                literal  => 'ccc',
            )
        )
    )
), $expression;

