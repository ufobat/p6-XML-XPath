use v6.c;

use Test;
use XML::XPath;

plan 10;

my $x = XML::XPath.new(xml => q:to/ENDXML/);
<AAA>
<BBB id='b1'/>
<BBB name=' bbb '/>
<BBB name='bbb'/>
</AAA>
ENDXML

my $set;
$set = $x.find('//BBB[@id="b1"]');
is $set.nodes.elems, 1 , 'found one node';
is $set.nodes[0].name, 'BBB', 'node name is BBB';

$set = $x.find('//BBB[@name="bbb"]');
is $set.nodes.elems, 1 , 'found one attrib';
is $set.nodes[0].name, 'BBB', 'node name is BBB';

$set = $x.find('//BBB[normalize-space(@name)="bbb"]');
is $set.nodes.elems, 3 , 'found one node';
is $set.nodes[0].name, 'BBB', 'node name is BBB';

done-testing;
