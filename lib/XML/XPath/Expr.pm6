use v6.c;

class XML::XPath::Expr {
    has $.expression;
    has $.operator;
    has $.next;
    has @.predicates;
}
