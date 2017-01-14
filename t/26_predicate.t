use v6.c;

use Test;
use XML::XPath;

plan 5;

my $x = XML::XPath.new(debug => 1, xml => q:to/ENDXML/);
<xml>
    <a>
        <b>some 1</b>
        <b>value 1</b>
    </a>
    <a>
        <b>some 2</b>
        <b>value 2</b>
    </a>
</xml>
ENDXML

# Don't set namespace prefixes - uses element context namespaces
my $set;

# value 1 and value 2
$set = $x.find('//a/b[2]');
is $set.elems, 2, 'found 2 nodes';

# value 1
$set = $x.find('(//a/b)[2]');
is $set.elems, 1, 'found 1 nodes';

done-testing;

