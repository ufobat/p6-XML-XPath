use v6.c;
use XML::XPath::Expr;
use XML::XPath::Step;

class XML::XPath::Actions {
    method Expr($/) {
        $/.make: $/<OrExpr>.made;
    }
    method OrExpr($/) {
        my @tokens = $/<AndExpr>;
        my @operators = $/<OrOperator>;
        self!expression(@tokens, $/, @operators);
    }

    method AndExpr($/) {
        my @tokens = $/<EqualityExpr>;
        my @operators = $/<AndOperator>;
        self!expression(@tokens, $/, @operators);
    }

    method EqualityExpr($/) {
        my @tokens = $/<RelationalExpr>;
        my @operators = $/<EqualityOperator>;
        self!expression(@tokens, $/, @operators);
    }

    method RelationalExpr($/) {
        my @tokens = $/<AdditiveExpr>;
        my @operators = $/<RelationalOperator>;
        self!expression(@tokens, $/, @operators);
    }

    method AdditiveExpr($/) {
        my @tokens = $/<MultiplicativeExpr>;
        my @operators = $/<AdditiveOperators>;
        self!expression(@tokens, $/, @operators);
    }

    method MultiplicativeExpr($/) {
        my @tokens = $/<UnaryExpr>;
        my @operators = $/<MultiplicativeOperator>;
        self!expression(@tokens, $/, @operators);
    }

    method UnaryExpr($/) {
        my $union-expression = $/<UnionExpr>;
        my $operator-prefix = $/<UnaryOperator>;
        my $expr = XML::XPath::Expr.new(
            expression => $union-expression.made,
            operator   => $operator-prefix,
        );
    }

    method UnionExpr($/) {
        my @tokens = $/<PathExpr>;
        my @operators = $/<UnionOperator>;
        self!expression(@tokens, $/, @operators);
    }

    method !expression(@tokens, $/, @operators) {
        die 'at least 1 *Expr required' if @tokens.elems < 1;
        my $last_expression;
        for @tokens.kv -> $i, $token {
            my $expression = $token.made;
            my $expr = XML::XPath::Expr.new(:$expression);
            if ($last_expression) {
                $last_expression.operator(@operators[$i-1].made);
                $last_expression.next($expr);
            }
            $last_expression = $expression;
        }
        $/.make: $last_expression;
    }

    method FilterExpr($/) {
        my $primary-expr = $/<PrimaryExpr>;
        my @predicates   = $/<Predicate>;
        my $expr         = $primary-expr.made;
        $expr.predicates = @predicates>>.made;
        $/.make: $expr;
    }

    method PrimaryExpr($/) {
        X::NYI.new(feature => 'PrimaryExpr').throw;
    }

    method RelativeLocationPath($/) {
        X::NYI.new(feature => 'RelativeLocationPath').throw;
    }
    method LocationPath($/) {
        X::NYI.new(feature => 'LocationPath').throw;
    }
    method Step($/) {
        my $step;
        if $/<AbbreviatedStep>:exists {
            # . or ..
            $step = XML::XPath::Step.new(
                axis    => 'child',
                literal => $/<AbbreviatedStep>.Str,
            );
        }
        else {
            if $/<AxisSpecifier> eq '' {
                $step = XML::XPath::Step.new(
                    axis => 'child',
                    literal => $<NodeTest>.made,
                );
            } elsif $/<AxisSpecifier> eq '@' {
                $step = XML::XPath::Step.new(
                    axis => 'attribute',
                    literal => $<NodeTest>.made,
                );
            } else {
                my $axis = $/<AxisSpecifier>.substr(0,*-2);
                $step = XML::XPath::Step.new(
                    :$axis,
                    literal => $<NodeTest>.made
                );
            }
        }
        my @predicates   = $/<Predicate>;
        $step.predicates = @predicates>>.made;
        $/.make: $step;
    }
    method NodeTest($/) {
        if $/<NameTest>:exists {
            $/.make: ~ $/<NameTest>;
        }
        elsif $/<NodeType>:exists {
            X::NYI.new(feature => 'NodeTest').throw;
        }
        else {
            # processing-instruction (<Literal>)
            X::NYI.new(feature => 'NodeTest').throw;
        }
    }
    method Predicate($/) {
        $/.make: $/<PredicateExpr>.made;
    }
    method PredicateExpr($/) {
        $/.make: $/<Expr>.made;
    }
    method AbbreviatedStep($/) {
        X::NYI.new(feature => 'AbbreviatedStep').throw;
    }
    method AxisSpecifier($/) {
        $/.make: ~$/;
    }
}
