package Foltia::ConfigLoader;
use strict;
use warnings;
use YAML ();
use Storable;

sub setup {
    my ( $class ) = @_;
    #XXX mockup
}

sub load {
    my ( $class, $stuff ) = @_;

    my $config;

    if ( ref $stuff && ref $stuff eq 'HASH' ) {
        $config = Storable::dclone($stuff);
    }
    else {
        open my $fh, '<:utf8', $stuff or die $!;
        $config = YAML::LoadFile($fh);
        close $fh;
    }

    return $config;
}

1;
__END__

=head1 NAME

Foltia::ConfigLoader - configuration file loader for Foltia

=head1 DESCRIPTION

INTERNAL USE ONLY
