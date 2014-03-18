package MyMenu;

use strict;
use warnings;

our $VERSION = '0.01';

# load additional modules here
use Term::ANSIScreen        qw();
use Term::ReadLine;


#> methods
#> ----------------------------------------------------------------------

# MyMenu->new(
#   head  => 'printf-format for header; should contain a %s for title',
#   entry => 'printf-format for entries; needs 2 %s for number and label',
#   title => 'foo',
#   items => [ { label => 'label text', code => \&sub }, ... ],
#   prompt => 'string for prompting user'
#
#   input of 'q' or 'Q' exits menu
# );
sub new {
    my $class = shift;
    my $self  = {};

    bless $self, ref($class)||$class;

    $self->_init( @_ );

    return $self;
}


sub _init {
    my $self = shift;
    my %args = @_;

    $self->{head} = $args{head} // <<HEAD;
-------------------------------------------------
 %s
-------------------------------------------------
HEAD
    $self->{entry} = $args{entry} // " %2s) %s\n";
    $self->{title} = $args{title} // 'Menu';
    $self->{items} = $args{items} // [];

    $self->{term} = Term::ReadLine->new($self->{title});
    $self->{prompt} = $args{prompt} // 'Your selection: ';

    return $self;
}



sub show {
    my $self = shift;

    # clear screen and position cursor at top left
    print Term::ANSIScreen::cls(), Term::ANSIScreen::locate();

    # print header template filled with title
    printf $self->{head}, $self->{title};

    # show menu entries
    my $i = 0;
    my @dispatch;
    for my $hRef ( @{ $self->{items} } ) {
        printf $self->{entry}, $i, $hRef->{label};
        $dispatch[$i++] = $hRef->{code};
    }
    print "\n";
    printf $self->{entry}, 'q', 'exit/abort/quit';

    # show prompt and process user input
    my $T = $self->{term};
    my $prompt = $self->{prompt};
    while ( defined( my $answer = $T->readline($prompt) ) ) {
        next    if $answer !~ m{\A [\dqQ]+ \z}x;
        last    if $answer =~ m{\A [qQ]+   \z}x;
        # call corresponding function
        $dispatch[$answer]->()  if $answer < $i;
    }
}


1;

__END__
