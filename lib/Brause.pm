package Brause;

use common::sense;
use IO::Socket::SSL qw(inet4);
use Template::Alloy;
use XML::Twig;

=head1 NAME

brause - a commandline EPP client

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use brause;

    my $foo = brause->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 talk

This is the only public function and it only expects the data to be sent
and the config values. It returns the data structures we got back from
the EPP server. There is no parsing done in the moment so all the
responses are ust plain XML snippets.

=cut

sub talk {
    my ( $data, $conf ) = @_;

    my $res = _send( $data, $conf );
    return $res;
}

=head2 _template

This internal function parses the data structure into our XML template
and returns the full XML request.
It expects a 'template_path' config value with the path to the relevant
template tree.

=cut

sub _template {
    my ( $data, $conf ) = @_;
    $data->{command} = $data->{command} . '.tt';
    my $t = Template::Alloy->new( INCLUDE_PATH => [ $conf->{template_path} ], );
    my $template = '';
    $t->process( 'frame.tt', $data, \$template ) || die $t->error;
    return $template;
}

=head2 _send

This internal function connects to the EPP server, reads the greeting
and logs in and then send the XML template we want to send. The response
has the greeting, the response from the login and the response from the
command we ran.

=cut

sub _send {
    my ( $data, $conf ) = @_;

    my $client;
    my $t= new XML::Twig;

    if ( $conf->{ssl_cert} ) {
        $client = new IO::Socket::SSL(
            PeerAddr      => $conf->{host},
            PeerPort      => $conf->{port},
            #LocalAddr     => $conf->{myip},
            Blocking      => 1,
            SSL_key_file  => $conf->{ssl_key},
            SSL_cert_file => $conf->{ssl_cert},
            SSL_use_cert  => 1,
        );
    }
    else {
        $client = new IO::Socket::SSL(
            PeerAddr  => $conf->{host},
            PeerPort  => $conf->{port},
            #LocalAddr => $conf->{myip},
            Blocking  => 1,
        );
    }
    die "Could not open socket: " . IO::Socket::SSL::errstr() . "\n"
      unless defined $client;

    my $greet;

    my $length = 0;

    my $read;
    # read lentgh (in Bytes)
    read( $client, $read, 4 );
    $length = unpack( "N", $read );
    $length -= 4;    # the length bit itself

    # read until $length bytes read
    while ( $length > 0 ) {
        $length -= read( $client, $read, $length );
        $greet .= $read;
    }

    if($conf->{debug}){
        print "greeting from the server:\n";
        $t->parse($greet);
        $t->set_pretty_print( 'indented');
        $t->print;
        print "----------\n";
    }

    my @response;
    foreach my $req ( @{$data->{step}} ) {
        my $request = _template( $req, $conf );
        if($conf->{debug}){
            print "sending this template:\n";
            $t->parse($request);
            $t->set_pretty_print( 'indented');
            $t->print;
            print "----------\n";
        }

        my $req = sprintf( "%s%s", _lE2bE( length($request) + 4 ), $request );
        print $client $req;
        my $stream;
        my $read;
        my $length = 0;

        # read lentgh (in Bytes)
        read( $client, $read, 4 );
        $length = unpack( "N", $read );
        $length -= 4;    # the length bit itself

        # read until $length bytes read
        while ( $length > 0 ) {
            $length -= read( $client, $read, $length );
            $stream .= $read;
        }
        if($conf->{debug}){
            print "recieved this response:\n";
            $t->parse($stream);
            $t->set_pretty_print( 'indented');
            $t->print;
            print "----------\n";
        }
        push( @response, $stream );
    }
    return { greet => $greet, response => \@response };
}

=head2 _lE2bE

This internal function converts little endian to big endian as network
byte order as defined in the EPP RFCs is normally not what we have on a
machine running this code base.

=cut

sub _lE2bE {
    my $number = shift;
    my ( $c, @numbers ) = (0);
    for ( my $c = 0 ; $c < 4 ; ++$c ) {
        push @numbers, $number % 256;
        $number >>= 8;
    }
    return
      sprintf( "%c%c%c%c", $numbers[3], $numbers[2], $numbers[1], $numbers[0] );
}

=head1 AUTHOR

Lenz Gschwendtner, C<< <norbu09 at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-brause at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=brause>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc brause


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=brause>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/brause>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/brause>

=item * Search CPAN

L<http://search.cpan.org/dist/brause/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2010 Lenz Gschwendtner.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;    # End of brause
