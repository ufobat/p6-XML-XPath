use v6.c;

role XML::XPath::Result {
    ## method String { ... }
    ## method Boolean { ... }
    ## method Number {}
    method Str { ... }
    method Bool { ... }
    method Int { ... }
    method equals($other) { ... }

#    method ResultList {
#        my $resultlist = XML::XPath::Result::ResultList.new;
#        $resultlist.add: self;
#        return $resultlist;
#    }
}
