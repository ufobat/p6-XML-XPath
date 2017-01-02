use v6.c;
#use Grammar::Debugger;

grammar XML::XPath::Grammar {
    token TOP { <Expr> }

    # https://www.w3.org/TR/1999/REC-xpath-19991116/
    # [1]
    token LocationPath {
        <RelativeLocationPath>
        | <AbsoluteLocationPath>
    }

    # [2]
    # [10] token AbbreviatedAbsoluteLocationPath
    token AbsoluteLocationPath {
        <StepOperator> <RelativeLocationPath>?
    }

    # [3]
    #token RelativeLocationPath {
    #    <Step>
    #    | <RelativeLocationPath> x'/' <Step>
    #    | <AbbreviatedRelativeLocationPath>
    #}
    # [11]
    #token AbbreviatedRelativeLocationPath {
    #    <RelativeLocationPath> '//' <Step>
    #}
    # rewrite wihtout infinite loop
    token RelativeLocationPath {
        <Step>+  % <StepOperator>
    }
    token StepOperator { ['/' | '//'] }

    # [4]
    token Step {
        <AxisSpecifier> <NodeTest> <Predicate>*
        | <AbbreviatedStep>
    }

    # [13]
    # [5]
    # [6]
    token AxisSpecifier {
        'ancestor::'
        | 'ancestor-or-self::'
        | 'attribute::'
        | 'child::'
        | 'descendant::'
        | 'descendant-or-self::'
        | 'following::'
        | 'following-sibling::'
        | 'namespace::'
        | 'parent::'
        | 'preceding::'
        | 'preceding-sibling::'
        | 'self::'
        | '@'
        | ''
    }

    # [7]s
    token NodeTest {
        <NameTest>
        | <NodeType> '()'
        | 'processing-instruction' '(' <Literal> ')'
    }

    # [8]
    token Predicate { '[' <PredicateExpr> ']' }

    # [9]
    token PredicateExpr { <Expr> }

    # [12]
    token AbbreviatedStep { '.' | '..' }

    # [14]
    token Expr   { <OrExpr> }

    # [15]
    token PrimaryExpr {
        <VariableReference>
        | '(' <Expr> ')'
        | <Literal>
        | <Number>
        | <FunctionCall>
    }

    # [16]
    token FunctionCall {
        <FunctionName> '(' [ <Argument>* % ',' ] ')'
    }

    # [17]
    token Argument { <Expr> }

    # [18]
    token UnionExpr { <PathExpr>+ % <UnionOperator> }
    token UnionOperator { '|' }

    # [19]
    token PathExpr {
        <FilterExpr> [ <StepOperator> <RelativeLocationPath> ]?
        | <LocationPath>
    }

    # [20]
    token FilterExpr {
        <PrimaryExpr> <Predicate>*
    }

    # [21]
    token OrExpr { <AndExpr>+ % <OrOperator> }
    token OrOperator { 'or' }

    # [22]
    token AndExpr { <EqualityExpr>+ % <AndOperator> }
    token AndOperator { 'and' }

    # [23]
    rule EqualityExpr { <RelationalExpr>+ % <EqualityOperator> }
    token EqualityOperator { ['=' || '!=' ] }

    # [24]
    token RelationalExpr { <AdditiveExpr>+ % <RelationalOperator> }
    token RelationalOperator { [ [ '<' | '>' ] '='? ] }

    # [25]
    token AdditiveExpr { <MultiplicativeExpr>+ % <AdditiveOperators> }
    token AdditiveOperators { [ '+' | '-'] }

    # [34]
    # [26]
    token MultiplicativeExpr { <UnaryExpr>+ % <MultiplicativeOperator> }
    token MultiplicativeOperator { ['*' | 'div' | 'mod' ] }

    # [27]
    token UnaryExpr { <UnaryOperator> <UnionExpr> }
    token UnaryOperator { '-'* }

    # [29]
    token Literal {
        '"'   <-[ " ]>* '"'
        | "'" <-[ ' ]>* "'"
    }
    #'
    # [30]
    # [31]
    token Number {
        \d+ [ '.' \d *]?
        | '.' \d+
    }

    # [35]
    token FunctionName {
        <QName>
        # except <NodeType>
        # look ahead
    }

    # [36]
    token VariableReference { '$' <QName> }

    # [37]
    token NameTest {
        '*'
        | <NCName> ':' '*'
        | <QName>
    }

    # [38]
    token NodeType {
        'comment'
        | 'text'
        | 'processing-instruction'
        | 'node'
    }

    # https://www.w3.org/TR/REC-xml-names/#NT-QName
    # [7]
    token QName {
        <PrefixedName>
        | <UnprefixedName>
    }

    # [8]
    token PrefixedName { <Prefix> ':' <LocalPart> }

    # [9]
    token UnprefixedName { <LocalPart> }

    # [10]
    token Prefix { <NCName> }

    # [11]
    token LocalPart { <NCName> }

    # https://www.w3.org/TR/REC-xml-names/#NT-NCName
    # [4]
    # TODO
    # [4]   	NameStartChar	   ::=   	":" | [A-Z] | "_" | [a-z] | [#xC0-#xD6] | [#xD8-#xF6] | [#xF8-#x2FF] | [#x370-#x37D] | [#x37F-#x1FFF] | [#x200C-#x200D] | [#x2070-#x218F] | [#x2C00-#x2FEF] | [#x3001-#xD7FF] | [#xF900-#xFDCF] | [#xFDF0-#xFFFD] | [#x10000-#xEFFFF]
    # [4a]   	NameChar	   ::=   	NameStartChar | "-" | "." | [0-9] | #xB7 | [#x0300-#x036F] | [#x203F-#x2040]
    # [5]   	Name	   ::=   	NameStartChar (NameChar)*ken NCName {
    token NCName {
        # https://www.w3.org/TR/REC-xml/#NT-Name
        <:L> <[\w\-\.] - [:]>*
    }

}
