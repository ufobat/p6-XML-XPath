use XML;
use XML::XPath::Result;
use XML::XPath::Result::ResultList;
use XML::XPath::Actions;
use XML::XPath::Grammar;

class XML::XPath {
    has $.document;
    has $.debug is rw = 0;

    submethod BUILD(:$file, :$xml, :$document) {
        my $doc;
        if $document {
            $doc = $document;
        }
        elsif $file {
            die "file $file is not readable" unless $file.IO.r;
            $doc = from-xml-file($file);
        }
        elsif $xml {
            $doc = from-xml($xml);
        }
        $!document = $doc;
    }

    method find(Str $xpath) {
        my $parsed-xpath   = self.parse-xpath($xpath);
        my $start-nodeset  = XML::XPath::Result::ResultList.new();
        $start-nodeset.add: $.document;
        return $parsed-xpath.evaluate($start-nodeset);
    }

    method parse-xpath(Str $xpath) {
        my $actions        = XML::XPath::Actions.new(:$.debug);
        my $match          = XML::XPath::Grammar.parse($xpath, :$actions);
        say $match if $.debug;
        my $parsed-xpath   = $match.ast;
        return $parsed-xpath;
    }
}
