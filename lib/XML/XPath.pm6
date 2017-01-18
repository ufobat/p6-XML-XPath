use XML;
use XML::XPath::Actions;
use XML::XPath::Grammar;

class XML::XPath {
    has $.document;
    has $.debug is rw = 0;
    has %.registered-namespaces is rw;

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

    method find(Str $xpath, Bool :$to-list) {
        my %*NAMESPACES  = %.registered-namespaces;
        my $parsed-xpath = self.parse-xpath($xpath);
        my $result       = $parsed-xpath.evaluate($.document, 0, 1);
        if $result ~~ Array && $result.elems == 1 && not $to-list {
            return $result[0];
        } elsif $result.elems == 0 && not $to-list {
            return Nil;
        }
        return $result;
    }

    method parse-xpath(Str $xpath) {
        my $actions        = XML::XPath::Actions.new(:$.debug);
        my $match          = XML::XPath::Grammar.parse($xpath, :$actions);
        say $match if $.debug;
        my $parsed-xpath   = $match.ast;
        return $parsed-xpath;
    }

    method set-namespace(Pair $ns) {
        %.registered-namespaces{ $ns.key } = $ns.value;
    }

    method clear-namespaces {
        %.registered-namespaces = ();
    }
}
