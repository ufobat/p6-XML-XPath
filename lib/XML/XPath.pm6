use XML;
use XML::XPath::Grammar;

class XML::XPath {
    has $.document;

    submethod BUILD(:$file, :$string) {

        my $doc;
        if $file {
        }
        elsif $string {
            $doc = XML.from-xml($string);
        }
        $!document = $doc;
    }

    method findnodes(Str $xpath) {
        my $match = XML::XPath::Grammar.parse($xpath);

    }
}
