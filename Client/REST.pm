package LanguageDetection::Client::REST;
# ABSTRACT: Perl client for the LanguageDetection REST API

use Moo;
use JSON;
use Carp;
use HTTP::Tiny;


has url => (
    is      => 'ro',
    builder => '_build_url',
);
has api_key (
    is => 'ro',
    required => 1,
);


# In case URL does change at some point, allow users to set it via creation arg.
# Additionally, and for convenience, enable passing it via ENV
sub _build_url {
    my ($self, $arg) = @_;
    my $arg_url = $arg
        ? $arg
        : $ENV{language_detection_api_url};
    return $arg_url
        ? $arg_url
        : 'http://ws.detectlanguage.com/0.2/detect';
}

sub detect_language {
    my ($self, $text) = @_;
    die "A text argument to detect language in is mandatory"  unless($text);

    my $payload = {
        q   => $text,
        key => $self->api_key,
    };

    my $res = HTTP::Tiny->new->request('POST', $self->url, {
        content => encode_json $payload,
    });
    my $decoded_res = decode_json $res->{content};
    my $det  = shift $decoded_res->{data}->{detections};
    my $lang = {
        language   => $det->{language},
        reliable   => $det->{isReliable},
        confidence => $det->{confidence},
    };
    return $res->{success}
        ? {success => 1, content => $lang}
        : {success => 0, reason => "$res->{status} - $res->{reason}: $res->{content}"};
} 

1;
