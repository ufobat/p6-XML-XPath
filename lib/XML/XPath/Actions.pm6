use v6.c;
use XML::XPath::Expr;
use XML::XPath::Step;
use Data::Dump;

class XML::XPath::Actions {
    has $.debug;
    method mymake($/, $made, Int :$level = 1) {
        my $caller = callframe($level);
        if $.debug {
            my Str $dump = $made.gist.chars > 30
            ?? "\n" ~ Dump($made, :skip-methods(True))
            !! $made.gist;

            say "called make from { $caller.code.gist } setting it to: $dump";
        }
        $/.make: $made;
    }

    method TOP($/) {
        self.mymake($/, $/<Expr>.made);
    }

    method Expr($/) {
        self.mymake($/, $/<OrExpr>.made);
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

    method UnionExpr($/) {
        my @tokens = $/<PathExpr>;
        my @operators = $/<UnionOperator>;
        self!expression(@tokens, $/, @operators);
    }

    method !expression(@tokens, $/, @operators) {
        die 'at least 1 *Expr required' if @tokens.elems < 1;
        my $last_expression;
        my $first_expression;
        for @tokens.kv -> $i, $token {
            my $expression = $token.made;
            if ($last_expression) {
                $last_expression.operator = @operators[$i-1].Str;
                $last_expression.next     = $expression;
            }
            $last_expression = $expression;
            $first_expression = $expression unless $first_expression;
        }
        self.mymake($/, $first_expression, level => 2);
    }

    method UnaryExpr($/) {
        my $union-expression = $/<UnionExpr>;
        my $operator-prefix = $/<UnaryOperator>;
        my $expr = XML::XPath::Expr.new(
            expression => $union-expression.made,
            operator   => $operator-prefix.Str,
        );
        self.mymake($/, $expr);
    }

    method FilterExpr($/) {
        my $primary-expr = $/<PrimaryExpr>;
        my @predicates   = $/<Predicate>;
        my $expr         = $primary-expr.made;
        $expr.predicates = @predicates>>.made;
        self.mymake($/, $expr);
    }

    method PrimaryExpr($/) {
        my $expression = XML::XPath::Expr.new;
        if $/<VariableReference>:exists {
            X::NYI.new(feature => 'PrimaryExpr - VariableReference').throw;
        } elsif $/<Expr>:exists {
            X::NYI.new(feature => 'PrimaryExpr - Expr').throw;
        } elsif $/<Literal>:exists {
            $expression.expression = $/<Literal>.made;
            self.mymake($/, $expression);
        } elsif $/<Number>:exists {
            $expression.expression = $/<Number>.Int;
            self.mymake($/, $expression);
        } else  {
            X::NYI.new(feature => 'PrimaryExpr - FunctionCall').throw;
        }
    }
    method Literal($/) {
        my $str = $/.Str;
        self.mymake($/, $str.substr(1,*-1));
    }

    method AbsoluteLocationPath($/) {
        my $operator = $/<StepOperator>.Str;

        my $step;
        if $/<RelativeLocationPath>:exists {
            $step          = $/<RelativeLocationPath>.made;
            $step.operator = $operator;
            $step.axis     = 'self';
        } else {
            $step = XML::XPath::Step.new(:$operator);
        }
        self.mymake($/, $step);
    }
    method RelativeLocationPath($/) {
        my @tokens = $/<Step>;
        my @operators = $/<StepOperator>;
        die 'at least 1 *Expr required' if @tokens.elems < 1;
        my $last_expression;
        my $first_expression;

        for @tokens.kv -> $i, $token {
            my $expression = $token.made;
            if ($last_expression) {
                $expression.operator  = @operators[$i-1].Str;
                $last_expression.expression = $expression;
            }
            $first_expression = $expression unless $first_expression;
            $last_expression = $expression;
        }
        self.mymake($/, $first_expression);
    }
    method LocationPath($/) {
        my $path;
        if $/<RelativeLocationPath>:exists {
            $path = $/<RelativeLocationPath>.made;
        } else {
            $path = $/<AbsoluteLocationPath>.made;
        }
        self.mymake($/, $path);
    }
    method PathExpr($/) {
        if $/<LocationPath>:exists {
            self.mymake($/, $/<LocationPath>.made);
        } else {
            my $filter = $/<FilterExpr>.made;
            if $/<StepOperator>:exists {
                my $stepoperator = $/<StepOperator>.Str;
                my $rlp = $/<RelativeLocationPath>.made;
                $rlp.operator = $stepoperator;
                $filter.expression: $rlp;
            }
            self.mymake($/, $filter);
        }

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
                my $literal = $/<NodeTest>.made;
                $step = XML::XPath::Step.new(
                    axis => 'child',
                    literal => $literal,
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
        self.mymake($/, $step);
    }
    method NodeTest($/) {
        if $/<NameTest>:exists {
            self.mymake($/, ~ $/<NameTest>);
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
        self.mymake($/, $/<PredicateExpr>.made);
    }
    method PredicateExpr($/) {
        self.mymake($/, $/<Expr>.made);
    }
    method AbbreviatedStep($/) {
        X::NYI.new(feature => 'AbbreviatedStep').throw;
    }
    method AxisSpecifier($/) {
        self.mymake($/, ~$/);
    }
}
