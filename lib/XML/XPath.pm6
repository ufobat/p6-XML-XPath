use XML;
use XML::XPath::Actions;
use XML::XPath::Grammar;

class XML::XPath {
    has $.document;

    submethod BUILD(:$file, :$string, :$document) {
        my $doc;
        if $document {
            $doc = $document;
        }
        elsif $file {
        }
        elsif $string {
            $doc = XML.from-xml($string);
        }
        $!document = $doc;
    }

    method find(Str $xpath) {
        my $actions = XML::XPath::Actions.new();
        my $match = XML::XPath::Grammar.parse($xpath, :$actions);
        say $match;
        my $parsed-xpath = $match.ast;
        return $parsed-xpath;
    }
}
