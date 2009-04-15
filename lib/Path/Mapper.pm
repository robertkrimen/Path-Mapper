package Path::Mapper;

use warnings;
use strict;

=head1 NAME

Path::Mapper - Map a virtual path to an actual one

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.010';


=head1 SYNOPSIS

    my $mapper = Path::Mapper->new( base => '../' )
    $mapper->map( a/b => /apple )

    $mapper->dir( /a/b/xyzzy/ ) # /apple/xyzzy
    $mapper->dir( /a/bxyzzy/ ) # ../a/bxyzzy

=head1 DESCRIPTION

Path::Mapper will map a virtual path to an actual one, doing a substitution based on the deepest common directory

Think of it as doing something like symbolic link resolution (though not exactly)

=cut

use Moose;
use Path::Abstract();
use Path::Class();

has _map => qw/is ro isa HashRef required 1/, default => sub { {} };

sub BUILD {
    my $self = shift;
    my $given = shift;
    
    my $base = $given->{base};
    $base = '' unless defined $base;

    $self->map( '' => $base );
}

=head1 METHODS

=head2 Path::Mapper->new( [ base => <base> ] )

Create a new C<Path::Mapper> object using <base> as the 'root' directory (by default, everything is mapped to be under that directory)

=head2 $mapper->base( <base> )

Change the base directory for $mapper to <base>

=head2 $mapper->map( <virtual> => <actual> )

Set up a map from <virtual> and anything under (e.g. <virtual>/*) to map to the <actual> prefix instead of the usual base

=head2 $mapper->map( <path> )

Return a 2-element list containing the actual base for this path and the path remainder. You probably don't want/need to use this method

=head2 $mapper->dir( <path> )

Map the virtual <path> to an actual one and return the result as a L<Path::Class::Dir> object

=head2 $mapper->file( <path> )

Map the virtual <path> to an actual one and return the result as a L<Path::Class::File> object

=head2 $mapper->path( <path> )

Map the virtual <path> to an actual one and return the result as a L<Path::Abstract> object

=cut

sub base {
    my $self = shift;
    if (@_) {
        $self->map( '' => shift );
    }
    return $self->_map->{''};
}

sub map {
    my $self = shift;
    if (@_ == 2) {
        my $virtual = shift;
        my $actual = shift;

        $virtual = '' unless defined $virtual; # Undefined behavior, set the base path
        $virtual = "/$virtual"; # Normalize with leading slash
        $virtual =~ s/\/*$//; # Get rid of trailing slash(es)
        $virtual = Path::Abstract->new( $virtual );
        $virtual = Path::Abstract->new( '' ) if $virtual->is_root;
        
        if (defined $actual) {
            $actual = Path::Abstract->new( $actual.'' ) if defined $actual;
            $self->_map->{$virtual.''} = $actual;
        }
        else {
            delete $self->_map->{$virtual.''};
        }
    }
    else {
        my $query = shift;
        $query = '' unless defined $query; # Undefined behavior

        $query = Path::Abstract->new( "/$query" ); # Normalize with leading slash
        my $query_ = $query.'';
        study $query_;

        my $found = '';
        for my $virtual (keys %{ $self->_map }) {
            if ($query =~ m/^$virtual(?:\/|$)/) {
                if (length $virtual > length $found) {
                    $found = $virtual;
                }
            }
        }

        my $base = $self->_map->{$found};
        my $remainder = substr $query, length $found;
        substr $remainder, 0, 1, '' if 0 == index $remainder, '/';
    
        my @result = ($base.'', $remainder);
        return wantarray ? @result : \@result;
    }
}

sub dir {
    my $self = shift;
    my ($base, $remainder) = $self->map( shift );
    return Path::Class::Dir->new( grep { length $_ } $base, $remainder );
}

sub file {
    my $self = shift;
    my ($base, $remainder) = $self->map( shift );
    return Path::Class::File->new( grep { length $_ } $base, $remainder );
}

sub path {
    my $self = shift;
    my ($base, $remainder) = $self->map( shift );
    return Path::Abstract->new( grep { length $_ } $base, $remainder );
}

=head1 AUTHOR

Robert Krimen, C<< <rkrimen at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-path-mapper at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Path-Mapper>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Path::Mapper


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Path-Mapper>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Path-Mapper>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Path-Mapper>

=item * Search CPAN

L<http://search.cpan.org/dist/Path-Mapper/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Robert Krimen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Path::Mapper
