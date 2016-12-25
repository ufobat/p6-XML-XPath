use v6.c;

class XML::XPath::Expr {
    has $.expression is rw;
    has $.operator is rw;
    has $.next;
    has @.predicates;
}
