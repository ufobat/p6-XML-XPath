use v6.c;

use Test;
use XML::XPath;

plan 8;

my $x = XML::XPath.new(xml => q:to/ENDXML/);
<AAA>
<BBB id='b1'/>
<BBB id='b2'/>
<BBB name='bbb'/>
<BBB/>
</AAA>
ENDXML

my $set;
$set = $x.find('//BBB[@id]');
is $set.nodes.elems, 2 , 'found one node';
is $set.nodes[0].name, 'BBB', 'node name is BBB';
is $set.nodes[1].name, 'BBB', 'node name is BBB';

$set = $x.find('//BBB[@name]');
is $set.nodes.elems, 1 , 'found one attrib';
is $set.nodes[0].name, 'BBB', 'node name is BBB';

$set = $x.find('//BBB[@*]');
is $set.nodes.elems, 3 , 'found one node';
is $set.nodes[0].name, 'BBB', 'node name is BBB';

$set = $x.find('//BBB[not(@*)]');
is $set.nodes.elems, 1 , 'found one node';
#is $set.nodes[0].name, 'BBB', 'node name is BBB';

done-testing;
