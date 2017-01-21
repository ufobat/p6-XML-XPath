use v6.c;

use Test;
use XML::XPath;

plan 2;

my $x = XML::XPath.new(xml => q:to/ENDXML/);
<page></page>
ENDXML

# substring("12345", 2, 3)              returns "234"
# substring("12345", 2)                 returns "2345"
# substring("12345", -2)                returns "12345"
# substring("12345", 1.5, 2.6)          returns "234"
# substring("12345", 0 div 0, 3)        returns ""
# substring("12345", 1, 0 div 0)        returns ""
# substring("12345", -1 div 0, 1 div 0) returns ""
# substring("12345", -42, 1 div 0)      returns "12345"
# substring("12345", 0, 1 div 0)        returns "12345"
# substring("12345", 0, 3)              returns "12"
# substring("12345", -1, 4)             returns "12"

my $set;
my $r = $x.find('substring("12345"), 2, 3');
is $r, "234";

done-testing
