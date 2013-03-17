use strict;
use warnings;

use Test::More;
use TryCatch;

my $last_context;
sub fun {
  my ($should_die) = @_;
  try {
    die 1 if $should_die;

    sub nested_A { return wantarray ? (1,2,3) : 7 }
    is_deeply([ nested_A ], [1,2,3], "nested subrutine in array context");
    is_deeply(scalar nested_A, 7, "nested subrutine in scalar context");

    $last_context = wantarray;
  }
  catch ($e where { /^1/ }) {
    sub nested_B { return wantarray ? (1,2,3) : 7 }
    is_deeply([ nested_B ], [1,2,3], "nested subrutine in array context");
    is_deeply(scalar nested_B, 7, "nested subrutine in scalar context");

    $last_context = wantarray;
  }
}

my @v;
$v[0] = fun();
is($last_context, '', "Scalar try context preserved");

@v = fun();
is($last_context, 1, "Array try context preserved");

fun();
is($last_context, undef, "void try context preserved");

$v[0] = fun(1);
is($last_context, '', "Scalar catch context preserved");

@v = fun(1);
is($last_context, 1, "Array catch context preserved");

fun(1);
is($last_context, undef, "void catch context preserved");

done_testing;
