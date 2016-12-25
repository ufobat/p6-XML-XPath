use v6.c;

use Test;
use XML::XPath;
use XML::XPath::Expr;
use XML::XPath::Step;

plan 7;

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
        literal    => 'dok',
        operator   => '//',
        expression => XML::XPath::Step.new(
            axis     => 'child',
            literal  => 'kap',
            operator => '/',
        )
    )
), $expression;

$expression = "//dok/kap[1]";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => '',
    expression => XML::XPath::Step.new(
        axis       => 'self',
        literal    => 'dok',
        operator   => '//',
        expression => XML::XPath::Step.new(
            axis     => 'child',
            literal  => 'kap',
            operator => '/',
            predicates => [
                           XML::XPath::Expr.new(
                               operator => '',
                               expression => XML::XPath::Expr.new(
                                   expression => 1,
                               ),
                           ),
                       ],
        )
    )
), $expression;

$expression = "//kap[@title='Nettes Kapitel']/pa";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => '',
    expression => XML::XPath::Step.new(
        axis       => 'self',
        literal    => 'kap',
        operator   => '//',
        predicates => [
                       XML::XPath::Expr.new(
                           operator => '=',
                           expression => XML::XPath::Step.new(
                               axis    => 'attribute',
                               literal => 'title',
                           ),
                           next => XML::XPath::Expr.new(
                               operator => '',
                               expression => XML::XPath::Expr.new(
                                   expression => 'Nettes Kapitel',
                               )
                           ),
                       ),
                   ],
        expression => XML::XPath::Step.new(
            axis     => 'child',
            operator => '/',
            literal  => 'pa',
        ),
    )
), $expression;

$expression = "//kap/pa[2]";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => '',
    expression => XML::XPath::Step.new(
        axis       => 'self',
        literal    => 'kap',
        operator   => '//',
        expression => XML::XPath::Step.new(
            axis     => 'child',
            literal  => 'pa',
            operator => '/',
            predicates => [
                           XML::XPath::Expr.new(
                               operator => '',
                               expression => XML::XPath::Expr.new(
                                   expression => 2,
                               ),
                           ),
                       ],
        )
    )
), $expression;

use Data::Dump;
my $xpath = $x.parse-xpath($expression);
say Dump $xpath, :skip-methods(True);
$expression = "//kap[2]/pa[@format='bold'][2]";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => '',
    expression => XML::XPath::Step.new(
        axis       => 'self',
        literal    => 'kap',
        operator   => '//',
        predicates => [
                       XML::XPath::Expr.new(
                           operator => '',
                           expression => XML::XPath::Expr.new(
                               expression => 2,
                           ),
                       ),
                   ],
        expression => XML::XPath::Step.new(
            axis       => 'child',
            operator   => '/',
            literal    => 'pa',
            predicates => [
                           XML::XPath::Expr.new(
                               operator => '',
                               expression => XML::XPath::Expr.new(
                                   expression => 'bold',
                               )
                           ),
                           XML::XPath::Expr.new(
                               operator => '',
                               expression => XML::XPath::Expr.new(
                                   expression => 2,
                               )
                           ),
                       ]
        ),
    )
), $expression;
exit;

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

