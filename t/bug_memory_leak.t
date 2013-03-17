use strict;
use warnings;
use Test::More;
use MooseX::Declare;
use Devel::Refcount qw/ refcount /;

BEGIN { use_ok "TryCatch" or BAIL_OUT("Cannot load TryCatch") };

class Test1 {
    method run() {
        use TryCatch;
        try { $self->calc(); }
        catch ($e where {/^123/}) {}
    }

    method calc() {
        return 2+3;
    }
};

my $obj = Test1->new;
is(refcount($obj), 1, "before test");

for (1..5) { $obj->run }

$TODO = "fix this memory-leak";
is(refcount($obj), 1, "after test");

done_testing;
