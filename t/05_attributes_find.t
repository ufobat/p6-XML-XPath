use v6.c;

use Test;
use XML::XPath;

plan 10;

my $x = XML::XPath.new(xml => q:to/ENDXML/);
<AAA>
<BBB id='b1'/>
<BBB id='b2'/>
<BBB name='bbb'/>
<BBB />
</AAA>
ENDXML

my $set;
$set = $x.find('//BBB[@id]');
is $set.nodes.elems, 2 , 'found one node';
is $set.nodes[0].value.name, 'BBB', 'node name is BBB';
is $set.nodes[1].value.name, 'BBB', 'node name is BBB';

$set = $x.find('//BBB[@name]');
isa-ok $set, XML::XPath::Result::Node, 'found one node';
is $set.value.name, 'BBB', 'node name is BBB';

$set = $x.find('//BBB[@*]');
is $set.nodes.elems, 3 , 'found one node';
is $set.nodes[0].value.name, 'BBB', 'node name is BBB';

$set = $x.find('//BBB[not(@*)]');
isa-ok $set, XML::XPath::Result::Node, 'found one node';
is $set.value.name, 'BBB', 'node name is BBB';
is $set.value.attribs.elems, 0, 'and node really has no attribute';

done-testing;
