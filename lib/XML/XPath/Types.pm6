subset Axis of Str where {$_ ~~ <child self attribute descendant descendant-or-self namespace parent ancestor following-sibling>.any};
subset Function of Str where {$_ ~~ <last position count id local-name namespace-uri name concat starts-with contain substring-before substring-after substring string-length normalize-space translate boolean not true false lang number sum floor ceiling round>.any};
subset Type of Str where { $_ ~~ <comment text node processing-instruction>.any}
subset Operator of Str where{$_ ~~ <Equal NotEqual SmallerThan GreaterThan SmallerEqual GreaterEqual Pipe Or And Multiply Div Mod Plus Minus UnaryMinus>.any}
