use v6.c;
use XML::XPath::Expr;

class XML::XPath::Actions {
    #method TOP($/) { }

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

    method !expression(@tokens, $/, @operators) {
        die 'at least 1 *Expr required' if @tokens.elems < 1;
        my $last_expression;
        for @tokens.kv -> $i, $token {
            my $expression = $token.made;
            my $expr = XML::XPath::Expr.new(:$expression);
            if ($last_expression) {
                $last_expression.operator(@operators[$i-1]);
                $last_expression.next($expr);
            }
            $last_expression = $expression;
        }
        $/.make: $last_expression;
    }

    method FALLBACK($name, $/) {
        say "FALLBACK for $name $/";
        $/.make: ~ $/;
    }
}
