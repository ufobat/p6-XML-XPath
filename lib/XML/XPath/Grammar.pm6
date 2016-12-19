use v6.c;
use Grammar::Debugger;

grammar XML::XPath::Grammar {
    token TOP { <Expr> }

    # https://www.w3.org/TR/1999/REC-xpath-19991116/
    # [1]
    token LocationPath {
        <RelativeLocationPath>
        | <AbsoluteLocationPath>
    }

    # [2]
    token AbsoluteLocationPath {
        '/' <RelativeLocationPath>?
        | <AbbreviatedAbsoluteLocationPath>
    }

    # [3]
    #token RelativeLocationPath {
    #    <Step>
    #    | <RelativeLocationPath> '/' <Step>
    #    | <AbbreviatedRelativeLocationPath>
    #}
    # [11]
    #token AbbreviatedRelativeLocationPath {
    #    <RelativeLocationPath> '//' <Step>
    #}
    # rewrite wihtout infinite loop
    token RelativeLocationPath {
        <Step> [ ['/' | '//'] <Step> ]*
    }

    # [4]
    token Step {
        <AxisSpecifier> <NodeTest> <Predicate>*
        | <AbbreviatedStep>
    }

    # [5]
    token AxisSpecifier {
        <AxisName> '::'
        | <AbbreviatedAxisSpecifier>
    }

    # [6]
    token AxisName {
        'ancestor'
        | 'ancestor-or-self'
        | 'attribute'
        | 'child'
        | 'descendant'
        | 'descendant-or-self'
        | 'following'
        | 'following-sibling'
        | 'namespace'
        | 'parent'
        | 'preceding'
        | 'preceding-sibling'
        | 'self'
    }

    # [7]
    token NodeTest {
        <NameTest>
        | <NodeType> '()'
        | 'processing-instruction' '(' <Literal> ')'
    }

    # [8]
    token Predicate { '[' <PredicateExpr> ']' }

    # [9]
    token PredicateExpr { <Expr> }

    # [10]
    token AbbreviatedAbsoluteLocationPath {
        '//' <RelativeLocationPath>
    }


    # [12]
    token AbbreviatedStep { '.' | '..' }

    # [13}
    token AbbreviatedAxisSpecifier { '@'? }

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
        <FunctionName>
        '('
        [ <Argument> [ ',' <Argument> ]* ]?
        ')'
    }

    # [17]
    token Argument { <Expr> }

    # [18]
    token UnionExpr {
        <PathExpr>
        | <UnionExpr> '|' <PathExpr>
    }

    # [19]
    token PathExpr {
        <LocationPath>
        | <FilterExpr>
        | <FilterExpr> '/'  <RelativeLocationPath>
        | <FilterExpr> '//' <RelativeLocationPath>
    }

    # [20]
    token FilterExpr {
        <PrimaryExpr>
        | <FilterExpr> <Predicate>
    }

    # [21]
    token OrExpr {
        <AndExpr>
        | <OrExpr> 'or' <AndExpr>
    }

    # [22]
    token AndExpr {
        <EqualityExpr>
        | <AndExpr> 'and' <EqualityExpr>
    }

    # [23]
    token EqualityExpr {
        <RelationalExpr>
        | <EqualityExpr> '='  <RelationalExpr>
        | <EqualityExpr> '!=' <RelationalExpr>
    }

    # [24]
    token RelationalExpr {
        <AdditiveExpr>
        | <RelationalExpr> '<'  <AdditiveExpr>
        | <RelationalExpr> '>'  <AdditiveExpr>
        | <RelationalExpr> '<=' <AdditiveExpr>
        | <RelationalExpr> '>=' <AdditiveExpr>
    }

    # [25]
    token AdditiveExpr {
        <MultiplicativeExpr>
        | <AdditiveExpr> '+' <MultiplicativeExpr>
        | <AdditiveExpr> '-' <MultiplicativeExpr>
    }

    # [26]
    token MultiplicativeExpr {
        <UnaryExpr>
        | <MultiplicativeExpr> <MultiplyOperator> <UnaryExpr>
        | <MultiplicativeExpr> 'div' <UnaryExpr>
        | <MultiplicativeExpr> 'mod' <UnaryExpr>
    }

    # [27]
    token UnaryExpr {
        <UnionExpr>
        | '-' <UnaryExpr>
    }

    # [28]
    token ExprToken {
        <.ws>?
        [
            '(' | ')' | '[' | ']' | '.' | '..' | '@' | ',' | '::'
            | <NameTest>
            | <NodeType>
            | <Operator>
            | <FunctionName>
            | <AxisName>
            | <Literal>
            | <Number>
            | <VariableReference>
        ]
        <.ws>?
    }

    # [29]
    token Literal {
        '"'   <-[ " ]>* '"'
        | "'" <-[ ' ]>* "'"
    }

    # [30]
    token Number {
        <Digits> [ '.' <Digits>?]?
        | '.' <Digits>
    }

    # [31]
    token Digits {
        \d+
    }

    # [32]
    token Operator {
        <OperatorName>
        | <MultipyOperator>
        | '/' | '//' | '|' | '+' | '-' | '=' | '!=' | '<' | '<=' | '>' | '>='
    }

    # [33]
    token OperatorName { 'and' | 'or' | 'mod' | 'div' }

    # [34]
    token MultiplyOperator { '*' }

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
    #h ttps://www.w3.org/TR/REC-xml-names/#NT-NCName
    # [4]
    token NCName {
        # https://www.w3.org/TR/REC-xml/#NT-Name
        <[\w] - [:]>+
    }

}
