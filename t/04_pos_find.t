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
isa-ok $set, XML::XPath::Result::Node, 'found one node';
is $set.value.name, 'BBB', 'node name is BBB';
is $set.value.attribs<id>, 'first', 'right node is selected';

$set = $x.find('/AAA/BBB[1]/@id');
isa-ok $set, XML::XPath::Result::String, 'found one node';
is $set, 'first', 'node attrib is first';

$set = $x.find('/AAA/BBB[last()]');
isa-ok $set, XML::XPath::Result::Node, 'found one node';
is $set.value.name, 'BBB', 'node name is BBB';
is $set.value.attribs<id>, 'last', 'right node is selected';

done-testing;
