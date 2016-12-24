use v6.c;

class XML::XPath::Step {
    # TODO
    #subset Axis of Str where {$_ ~~ any<>};
    #subset Test of Str where {$_ ~~ any<>};
    has Str $.axis;
    has Str $.test;
    has Str $.literal;
    has @.predicates;
}
