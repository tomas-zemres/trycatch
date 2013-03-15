package Mock::Animal;

package main;
use strict;
use warnings;
use Test::More;
use TryCatch;

BEGIN { use_ok "TryCatch" or BAIL_OUT("Cannot load TryCatch") };

# Mock objects
my $foo    = bless {}, "Mock::Foo";
my $cat    = bless {}, "Mock::Cat";
my $dog    = bless {}, "Mock::Dog";

push @Mock::Cat::ISA, 'Mock::Animal';
push @Mock::Dog::ISA, 'Mock::Animal';

isa_ok($cat, 'Mock::Animal');
isa_ok($dog, 'Mock::Animal');

sub test_catch_class {
    my ($mock_exception) = @_;

    try {
        die $mock_exception;
    }
    catch (Mock::Cat $e) {
        return "cat";
    }
    catch (Mock::Animal $e) {
        return "animal";
    }
    catch (Mock::Dog $e) {
        return "dog";
    }
    catch ($e) {
        return 'others';
    }
    return "error";
}

is( test_catch_class($cat),
    'cat',
    'Caught by cat-handler, because it is before animal-handler'
);
is( test_catch_class($dog),
    'animal',
    'Caught by animal-handler, because it is subclass of animal
        and animal-hadnler is before dog-handler'
);
is( test_catch_class($foo),
    'others',
    'Caught by others-handler'
);

done_testing();
