use strict;
use warnings;

use Test::More;
plan tests => 28;

use HTTP::Config;

sub j { join("|", @_) }

my $conf = HTTP::Config->new;
ok($conf->empty);
is($conf->entries, 0);
$conf->add_item(42);
ok(!$conf->empty);
is($conf->entries, 1);
is(j($conf->matching_items("http://www.example.com/foo")), 42);
is(j($conf->remove_items), 42);
is(j($conf->remove_items), '');
is($conf->matching_items("http://www.example.com/foo"), 0);
is($conf->matching_items('foo', 'bar', 'baz'), 0);
$conf->add({item => "http://www.example.com/foo", m_uri__HEAD => undef});
is($conf->entries, 1);
is($conf->matching_items("http://www.example.com/foo"), 0);
SKIP: {
	my $res;
	eval { $res = $conf->matching_items(0); };
	skip "can fails on non-object", 2 if $@;
	is($res, 0);
	eval { $res = $conf->matching(0); };
	ok(!defined $res);
}

$conf = HTTP::Config->new
	->add_item("always")
	->add_item("GET", m_method => ["GET", "HEAD"])
	->add_item("POST", m_method => "POST")
	->add_item(".com", m_domain => ".com")
	->add_item("secure", m_secure => 1)
	->add_item("not secure", m_secure => 0)
	->add_item("slash", m_host_port => "www.example.com:80", m_path_prefix => "/")
	->add_item("u:p", m_host_port => "www.example.com:80", m_path_prefix => "/foo")
	->add_item("success", m_code => "2xx")
;
is($conf->find(m_domain => ".com")->{item}, '.com');
my @found = $conf->find(m_domain => ".com");
is($#found, 0);
is($found[0]->{item}, '.com');

use HTTP::Request;
my $request = HTTP::Request->new(HEAD => "http://www.example.com/foo/bar");
$request->header("User-Agent" => "Moz/1.0");

is(j($conf->matching_items($request)), "u:p|slash|.com|GET|not secure|always");

$request->method("HEAD");
$request->uri->scheme("https");

is(j($conf->matching_items($request)), ".com|GET|secure|always");

is(j($conf->matching_items("http://activestate.com")), ".com|not secure|always");

use HTTP::Response;
my $response = HTTP::Response->new(200 => "OK");
$response->content_type("text/plain");
$response->content("Hello, world!\n");
$response->request($request);

is(j($conf->matching_items($response)), ".com|success|GET|secure|always");

$conf->remove_items(m_secure => 1);
$conf->remove_items(m_domain => ".com");
is(j($conf->matching_items($response)), "success|GET|always");

$conf->remove_items;  # start fresh
is(j($conf->matching_items($response)), "");

$conf->add_item("any", "m_media_type" => "*/*");
$conf->add_item("text", m_media_type => "text/*");
$conf->add_item("html", m_media_type => "html");
$conf->add_item("HTML", m_media_type => "text/html");
$conf->add_item("xhtml", m_media_type => "xhtml");

is(j($conf->matching_items($response)), "text|any");

$response->content_type("application/xhtml+xml");
is(j($conf->matching_items($response)), "xhtml|html|any");

$response->content_type("text/html");
is(j($conf->matching_items($response)), "HTML|html|text|any");

$response->request(undef);
is(j($conf->matching_items($response)), "HTML|html|text|any");

{
    my @warnings;
    local $SIG{__WARN__} = sub { push @warnings, grep { length } @_ };

    my $conf = HTTP::Config->new;
    $conf->add(owner => undef, callback => sub { 'bleah' });
    $conf->remove(owner => undef);

    ok(($conf->empty), 'found and removed the config entry');
    is(scalar(@warnings), 0, 'no warnings')
        or diag('got warnings: ', explain(\@warnings));
}
