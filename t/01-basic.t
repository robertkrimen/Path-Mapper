#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Most;

plan qw/no_plan/;

use Path::Mapper;
use Path::Class;
use Path::Abstract qw/path/;

my ($mapper);

sub _test($$$) {
    my ($virtual, $base, $remainder) = @_;

    my $combined = join '/', grep { length } ($base, $remainder);

    cmp_deeply( scalar $mapper->map( $virtual ), [ $base, $remainder ] );
    is( $mapper->file( $virtual ).'', file( $combined ).'' );
    is( $mapper->dir( $virtual ).'', dir( $combined ).'' );
    is( $mapper->path( $virtual ).'', path( $combined ).'' );
}

sub test {
    my $base = shift;

    $mapper = Path::Mapper->new( base => $base );
    $mapper->map( 'a/b' => '/apple' );
    $mapper->map( 'a/b/c' => '../banana' );
    $mapper->map( 'a/b/c/d/' => '/tmp/grape' );

    _test '/xyzzy', $base, 'xyzzy';
    _test '/a/b/xyzzy', '/apple', 'xyzzy';
    _test '/a/b/xyzzy/', '/apple', 'xyzzy/';
    _test '/a/bxyzzy', $base, 'a/bxyzzy';
    _test '/a/xyzzy', $base, 'a/xyzzy';
    _test '/a/xyzzy/', $base, 'a/xyzzy/';
    _test '/a/b/c', '../banana', '';
    _test '/a/b/c/', '../banana', '';
    _test '/a/b/c/xyzzy', '../banana', 'xyzzy';
    _test 'abcxyzzy', $base, 'abcxyzzy';
    _test '/a/b/c/d/xyzzy', '/tmp/grape', 'xyzzy';
}

test '';
test 'cherry';
test '/';
test 'grape/';
