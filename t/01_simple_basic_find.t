use v6.c;

use Test;
use XML::XPath;

plan 6;

my $x = XML::XPath.new(xml => q:to/ENDXML/);
<AAA>
    <BBB/>
    <CCC/>
    <BBB/>
    <CCC/>
    <BBB/>
    <!-- comment -->
    <DDD>
        <BBB/>
        Text
        <BBB/>
    </DDD>
    <CCC/>
</AAA>
ENDXML

my $set;
$set = $x.find("/AAA");
is $set.nodes.elems, 1 , 'found one node';
is $set.nodes[0].name, 'AAA', 'node name is AAA';

$set = $x.find("/AAA/BBB");
is $set.nodes.elems, 3 , 'found three nodes';
is $set.nodes[0].name, 'BBB', 'node name is BBB';

$set = $x.find("/AAA/DDD/BBB");
is $set.nodes.elems, 2 , 'found three nodes';
is $set.nodes[0].name, 'BBB', 'node name is BBB';

done-testing;
