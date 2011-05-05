package Net::HTTP::Spore::Middleware::OpenCalais;

use Moose;
use JSON;

extends 'Net::HTTP::Spore::Middleware';

has api_key => ( isa => 'Str', is => 'rw', predicate => 'has_api_key' );
has content_type =>
  ( isa => 'Str', is => 'rw', lazy => 1, default => 'text/raw' );

has _json_parser => (
    is      => 'rw',
    isa     => 'JSON',
    lazy    => 1,
    default => sub { JSON->new->utf8(1)->allow_nonref },
);

sub call {
    my ($self, $req) = @_;

    $req->header('x-calais-licenseID' => $self->api_key);
    $req->header('content-type' => $self->content_type);
    $req->header('outputformat' => 'application/json');

    return $self->response_cb(
        sub{
            my $res = shift;
            if ($res->body){
                my $content = $self->_json_parser->decode($res->body);
                $res->body($content);
            }
        }
    );
}

1;
