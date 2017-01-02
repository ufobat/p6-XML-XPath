use v6.c;

use Test;
use XML::XPath;

plan 6;

my $x = XML::XPath.new(xml => q:to/ENDXML/);
<AAA>
<XXX><DDD><BBB/><BBB/><EEE/><FFF/></DDD></XXX>
<CCC><DDD><BBB/><BBB/><EEE/><FFF/></DDD></CCC>
<CCC><BBB><BBB><BBB/></BBB></BBB></CCC>
</AAA>
ENDXML

my $set;
$set = $x.find("/AAA/CCC/DDD/*");
is $set.nodes.elems, 4 , 'found one node';
is $set.nodes[0].value.name, 'BBB', 'node name is BBB';

$set = $x.find("/*/*/*/BBB");
is $set.nodes.elems, 5 , 'found three nodes';
is $set.nodes[0].value.name, 'BBB', 'node name is BBB';

$set = $x.find("//*");
is $set.nodes.elems, 17 , 'found three nodes';
is $set.nodes[0].value.name, 'AAA', 'node name is BBB';

done-testing;
