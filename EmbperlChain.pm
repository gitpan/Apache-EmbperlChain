package Apache::EmbperlChain;

use Apache::OutputChain;
use HTML::Embperl ();
use strict;
use vars qw($VERSION @ISA);

$VERSION = '0.02';
@ISA = qw(Apache::OutputChain);
my $last_in_chain;

sub handler {
	my $r = shift;
	my $tied = tied *STDOUT;
	my $reftied = ref $tied;
	$last_in_chain = ($reftied eq 'Apache::OutputChain');
	Apache::OutputChain::handler($r, __PACKAGE__);
}

sub PRINT {
	my $self = shift;
	my $line = join '', @_;
	return unless length($line);

	# have Embperl output directly if its the last
	# handler in the chain
	if ($last_in_chain) {
		HTML::Embperl::Execute (
			{ input		=> \$line,
			  req_rec	=> Apache->request
			});
	}
	# otherwise pipe the output to the next handler
	else {
		my $output;
		HTML::Embperl::Execute (
			{ input         => \$line,
			  output	=> \$output,
			  req_rec	=> Apache->request
			});
		$self->Apache::OutputChain::PRINT($output);
	}
}

1;

__END__

=head1 NAME

Apache::EmbperlChain - process embedded perl in HTML in the OutputChain

=head1 SYNOPSIS

In the configuration of your apache add something like

    PerlModule Apache::EmbperlChain
    <Files *.html>
    SetHandler perl-script
    PerlHandler Apache::OutputChain Apache::EmbperlChain Apache::PassFile
    </Files>

This will cause all html files to be processed by Embperl.

Now this:

    <Location /foo>
    SetHandler perl-script
    PerlHandler Apache::OutputChain Apache::GzipChain Apache::EmbperlChain My::OwnHandler
    </Location>

Any request in the /foo subtree will be processed by My::OwnHandler. The output of that will
then be filtered by EmbperlChain, which will process any embedded Perl commands. That output
will then be compressed by GzipChain, which will deliver compressed content to the client.

=head1 STATUS

This is beta software, and the output chain mechanism itself is also beta.

You currently cannot mix perl's own C<print> statements that print to
STDOUT and the C<print> or C<write_client> methods in Apache.pm. If
you do that, you will very likely encounter empty documents and
probably core dumps too. Since Apache::OutputChain uses perl's C<print>
statement, you'll probably want to stick to that too.

=head1 DESCRIPTION

This module calls HTML::Embperl to process any output from another perl
handler.

The module seems to work without influencing the other handlers.

EmbperlChain processes every single buffer content it receives via the
output chain separately. Therefore care must be taken to print valid
embedded perl chunks in the content handler. It is recommended that
you use as few print statements as possible in conjunction with the
EmbperlChain. The Apache::PassFile module is an example of an efficient
file reader for this purpose.

=head1 PREREQUISITES

HTML::Embperl, Apache::OutputChain

=head1 AUTHOR

Eric Cholet, cholet@logilune.com

Documentation shamelessly copied from Apache::GzipChain by Andreas Koenig.

=head1 SEE ALSO

Apache::GzipChain, Apache::SSIChain

=cut
