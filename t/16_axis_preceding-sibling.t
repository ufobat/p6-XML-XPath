use v6.c;

use Test;
use XML::XPath;

plan 5;

my $x = XML::XPath.new(xml => q:to/ENDXML/);
<AAA>
    <BBB>
        <CCC/>
        <DDD/>
    </BBB>
    <XXX>
        <DDD>
            <EEE/>
            <DDD/>
            <CCC/>
            <FFF/>
            <FFF>
                <GGG/>
            </FFF>
        </DDD>
    </XXX>
    <CCC>
        <DDD/>
    </CCC>
</AAA>
ENDXML

my $set;
$set = $x.find('/AAA/XXX/preceding-sibling::*');
is $set.elems, 1, 'found one node';
is $set[0].value.name, 'BBB', 'found node is BBB';

$set = $x.find('//CCC/preceding-sibling::*');
is $set.elems , 4, 'found four nodes';

$set = $x.find('/AAA/CCC/preceding-sibling::*[1]');
is $set.value.name , 'XXX', 'found node XXX';

$set = $x.find('/AAA/CCC/preceding-sibling::*[2]');
is $set.value.name , 'BBB', 'found node BBB';

done-testing;
