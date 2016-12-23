use v6.c;

use Test;
use XML::XPath;

plan 1;

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

my @aaa = $x.find("/AAA");

is @aaa.elems, 1 , 'found one AAA';
say @aaa;

done-testing;
