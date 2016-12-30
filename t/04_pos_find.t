use v6.c;

use Test;
use XML::XPath;

plan 8;

my $x = XML::XPath.new(xml => q:to/ENDXML/);
<AAA>
<BBB id="first"/>
<BBB/>
<BBB/>
<BBB id="last"/>
</AAA>
ENDXML

my $set;
$set = $x.find('/AAA/BBB[1]');
is $set.nodes.elems, 1 , 'found one node';
is $set.nodes[0].name, 'BBB', 'node name is BBB';
is $set.nodes[0].attribs<id>, 'first', 'right node is selected';

$set = $x.find('/AAA/BBB[1]/@id');
is $set.nodes.elems, 1 , 'found one attrib';
is $set.nodes[0], 'first', 'node attrib is first';

$set = $x.find('/AAA/BBB[last()]');
is $set.nodes.elems, 1 , 'found one node';
is $set.nodes[0].name, 'BBB', 'node name is BBB';
is $set.nodes[0].attribs<id>, 'last', 'right node is selected';

done-testing;
