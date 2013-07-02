package Nephia::DSLModifier;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

use parent 'Exporter';

our @EXPORT = qw/before around after origin/;

sub origin ($) {
    my ($method_name) = @_;
    no strict 'refs';
    *{'Nephia::Core::'.$method_name}{CODE};
}

sub around ($&) {
    my ($method_name, $coderef) = @_;
    no strict 'refs';
    no warnings 'redefine';
    my $orig = Nephia::DSLModifier::origin($method_name) or die "specified unsupported DSL '$method_name'";
    *{'Nephia::Core::'.$method_name} = sub { $coderef->(@_, $orig) };
}

sub before ($&) {
    my ($method_name, $coderef) = @_;
    Nephia::DSLModifier::around($method_name, sub {
        my $orig = pop; 
        $coderef->(@_);
        $orig->(@_);
    });
}

sub after ($&) {
    my ($method_name, $coderef) = @_;
    Nephia::DSLModifier::around($method_name, sub {
        my $orig = pop; 
        my @res = $orig->(@_);
        $coderef->(@_);
        ( @res );
    });
}

1;
__END__

=encoding utf-8

=head1 NAME

Nephia::DSLModifier -  DSL Modifier feature for Nephia

=head1 SYNOPSIS

    use Nephia::DSLModifier;
    
    # fetch coderef of "res" DSL
    my $coderef = origin 'res';
    
    # add logic before "res" DSL
    before 'res' => sub {
        ...
    };
    
    # add logic after "res" DSL
    after 'res' => sub {
        ...
    };
    
    # modify "res" DSL
    around 'res' => sub {
        my $origin = pop;
        my $reponse = $origin->( @_ );
        ...
        return $response;
    };

=head1 DESCRIPTION

Nephia::DSLModifier provides modifier commands that modifies Nephia DSL.

=head1 LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut

