
: <<'=cut'
=pod

=head1 NAME

tap.sh - Useful subset of TAP (Test Anything Protocol) for shell scripts

=head1 SYNOPSIS

    . ./tap.sh

    plan 6

    ok '1 = 1' 'Make sure that one equals one'
    ok '1 != 2' 'Make sure that one is not two'

    is   2 2 'Two is two'
    isnt 2 3 'Two is not three'

    pass 'It worked!'
    fail 'Uh oh'

    diag 'This is a diagnostic message'
    note - <<NOTE
    Can also use a heredoc for diag and note
    NOTE

=head1 SEE ALSO

* https://testanything.org - TAP website

=head1 AUTHOR

Charles McGarvey <chazmcgarvey@brokenzipper.com>

=head1 LICENSE

This software is copyright (c) 2017 by Charles McGarvey.

This is free software, licensed under:

    The MIT (X11) License

=cut

next_test_number=1

plan() {
    _n=$1; shift
    echo "1..$_n"
}

ok() {
    _t=$1; shift
    _m=$1; shift
    if eval "test $_t"; then pass "$_m"; else fail "$_m"; fi
}

is() {
    _a=$1; shift
    _b=$1; shift
    _m=$1; shift
    if [ "$_a" = "$_b" ]
    then
        pass "$_m"
    else
        fail "$_m"
        note "Expected: $_b" "     Got: $_a"
    fi
}

isnt() {
    _a=$1; shift
    _b=$1; shift
    _m=$1; shift
    if [ "$_a" != "$_b" ]
    then
        pass "$_m"
    else
        fail "$_m"
        note "Expected: != $_b" "     Got: $_a"
    fi
}

pass() {
    echo "ok $next_test_number - $*"
    # shellcheck disable=SC2003
    next_test_number=$(expr "$next_test_number" + 1)
}

fail() {
    echo "not ok $next_test_number - $*"
    # shellcheck disable=SC2003
    next_test_number=$(expr "$next_test_number" + 1)
}

diag() {
    if [ "$1" != '-' ]
    then
        for _m in "$@"
        do
            echo "# $_m"
        done
    else
        while read -r _m
        do
            echo "# $_m"
        done
    fi
}

note() {
    diag "$@"
}

