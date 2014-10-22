package Maypole::Plugin::ColumnGroups;

use warnings;
use strict;

use Maypole::Config;
use NEXT;

our $VERSION = '0.2';

Maypole::Config->mk_accessors( qw( column_groups ) );

=head1 NAME

Maypole::Plugin::ColumnGroups - set up column groups in Maypole

=head1 SYNOPSIS

    use Maypole::Application qw( ColumnGroups -Debug2 ); 

    # Maypole will use the column 'name' or 'title', if it exists, or a primary 
    # key column that is not called 'id'. Otherwise, you need to tell Maypole 
    # what column to stringify objects to:
    __PACKAGE__->config->column_groups( { person => { Stringify => 'first_name' },
                                          car    => { Stringify => 'model' },
                                          widget => { Stringify => 'part_no' },
                                          
                                          article => { Editor   => [ qw( content keywords publish location ) ],
                                                       Writer   => [ qw( content keywords ) ],
                                                       Reviewer => [ qw( rating ) ],
                                                       },
                                          finance => { Editor => [ qw( invoice credit bribe entertainment ) ] },
                                          } );
                                          
    #
    # An example using Maypole::Plugin::Config::Apache:
    #
    PerlAddVar MaypoleColumnGroups "person => { Stringify => 'first_name' }"
    PerlAddVar MaypoleColumnGroups "car    => { Stringify => 'model' }"
    PerlAddVar MaypoleColumnGroups "widget => { Stringify => 'part_no' }"

    PerlAddVar MaypoleColumnGroups "article => { Editor   => [ qw( content keywords publish location ) ] }"
    PerlAddVar MaypoleColumnGroups "article => { Writer   => [ qw( content keywords ) ] }"
    PerlAddVar MaypoleColumnGroups "article => { Reviewer => [ qw( rating ) ] }"
    PerlAddVar MaypoleColumnGroups "finance => { Editor   => [ qw( invoice credit bribe entertainment ) ] }"

         
=head1 DESCRIPTION

Maypole use the C<Stringify> column group to decide which column to use when, for example, displaying a 
link to an object. If there is no C<Stringify> group, Maypole defaults to using the column 'name' or 'title', 
if it exists, or a primary key column that is not called 'id'. Otherwise, you need to tell Maypole what 
column to stringify objects on. 

Authorization could make heavy use of column groups to decide who has access 
to what columns of different tables. It's easy enough to set up column groups by hand, but it's also 
useful to be able to stuff all that information into the configuration data. 

Setting the C<Debug> flag to 2 or higher will print some info to C<STDERR> to confirm how the groups 
have been set up.

=head1 METHODS

=over

=item setup

=back
    
=cut

sub setup
{
    my $r = shift;
    
    $r->NEXT::DISTINCT::setup( @_ );
    
    # $table => { Group => $column or $columns }
    my $col_groups = $r->config->column_groups;
    
    my $loader = $r->config->loader;
    
    foreach my $table ( keys %$col_groups )
    {
        my $groups = $col_groups->{ $table };
        
        foreach my $group ( keys %$groups )
        {
            my $cols = $groups->{ $group };
            
            my @cols = ref( $cols ) eq 'ARRAY' ? @$cols : ( $cols );
            
            my $class = $loader->find_class( $table );
            
            $class->columns( $group => @cols );
            
            warn "Added column group '$group' with columns '@cols' to class '$class'\n" if $r->debug > 1;
        }
    }                                      
}

=head1 AUTHOR

David Baird, C<< <cpan@riverside-cms.co.uk> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-maypole-plugin-columngroups@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Maypole-Plugin-ColumnGroups>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2005 David Baird, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Maypole::Plugin::ColumnGroups
