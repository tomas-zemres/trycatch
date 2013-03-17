use strict;
use warnings;
use Test::More;

BEGIN { use_ok "TryCatch" or BAIL_OUT("Cannot load TryCatch") };

sub get_line_number {
    my ($code, $pattern) = @_;
    my ($before_pattern) = split $pattern, $code, 2;
    return scalar(split "\n", $before_pattern);
}

sub dump_code {
    my ($code) = @_;
    my ($dump, $linenr) = ("Tested code:\n", 0);
    foreach (split "\n", $code) {
        ++$linenr;
        $dump .= "   $linenr: $_\n";
    }
    diag "$dump\n";
}

sub test_code_warnings {
    my ($code, @expected_warnings) = @_;

    my @warnings;
    local $SIG{__WARN__} = sub { push @warnings, shift };
    eval $code;

    foreach my $expected (@expected_warnings) {
        my $linenr = get_line_number($code, $expected);
        like(
            shift @warnings,
            qr/^$expected at \(eval \d+\) line $linenr.\n$/,
            "Expected warning $expected at line number $linenr"
        ) or dump_code($code);
    }
    if (@warnings) {
        fail("There are aditional warnings:\n   "
                . join "\n   ", @warnings);
        dump_code($code);
    }
}

local $TODO = "Fix line-numbers in warnnigs";

test_code_warnings('
    try { warn "AAA"; die "123\n" }
    catch($e where {/^123/}) { warn "BBB" }
    warn "CCC";
',
    qw/ AAA BBB CCC /
);

test_code_warnings('
    try {
        warn "AAA";
        die "123\n";
    }
    catch($e where {/^123/}) {
        warn "BBB";
    }
    warn "CCC";
',
    qw/ AAA BBB CCC /
);

test_code_warnings('
    try {
        warn "AAA";

        warn "BBB";
        die "123\n";
    }


    catch($e where {/^123/}) {

        warn "CCC";

    }

    warn "DDD";
',
    qw/ AAA BBB CCC DDD /
);

done_testing;
