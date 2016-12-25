use v6.c;

use Test;
use XML::XPath;
use XML::XPath::Expr;
use XML::XPath::Step;

plan 3;

my $x = XML::XPath.new;
my $expression;

$expression = "/dok";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => '',
    expression => XML::XPath::Step.new(
        axis     => 'self',
        literal  => 'dok',
        operator => '/',
    )
), $expression;

$expression = "/*";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => '',
    expression => XML::XPath::Step.new(
        axis       => 'self',
        literal    => '*',
        operator   => '/',
    )
), $expression;

$expression = "//dok/kap";
is-deeply $x.parse-xpath($expression),
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
            next     => XML::XPath::Step.new(
                axis     => 'child',
                literal  => 'ccc',
                operator => '/',
            )
        )
    )
), $expression;

$expression = "//dok/kap[1]";
is-deeply $x.parse-xpath($expression),
Any, $expression;

$expression = "//kap[@title='Nettes Kapitel']/pa";
is-deeply $x.parse-xpath($expression),
Any, $expression;

$expression = "//kap/pa[2]";
is-deeply $x.parse-xpath($expression),
Any, $expression;

$expression = "//kap[2]/pa[@format='bold'][2]";
is-deeply $x.parse-xpath($expression),
Any, $expression;

$expression = "child::*";
is-deeply $x.parse-xpath($expression),
Any, $expression;

$expression = "child::pa";
is-deeply $x.parse-xpath($expression),
Any, $expression;

$expression = "child::text()";
is-deeply $x.parse-xpath($expression),
Any, $expression;

$expression = ".";
is-deeply $x.parse-xpath($expression),
Any, $expression;

$expression = "./*";
is-deeply $x.parse-xpath($expression),
Any, $expression;

$expression = "./pa";
is-deeply $x.parse-xpath($expression),
Any, $expression;

$expression = "pa";
is-deeply $x.parse-xpath($expression),
Any, $expression;

$expression = "attribute::*";
is-deeply $x.parse-xpath($expression),
Any, $expression;

$expression = "namespace::*";
is-deeply $x.parse-xpath($expression),
Any, $expression;

$expression = "//kap[1]/pa[2]/text()";
is-deeply $x.parse-xpath($expression),
Any, $expression;

