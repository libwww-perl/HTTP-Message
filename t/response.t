# Test extra HTTP::Response methods.  Basic operation is tested in the
# message.t test suite.

use strict;
use warnings;

use Test::More;
plan tests => 68;

use HTTP::Date;
use HTTP::Request;
use HTTP::Response;

# make sure we get no failures from undefined response values
{
    my $req = HTTP::Response->new();
    is($req->is_success(), undef, 'Empty res: is_success');
    is($req->is_info(), undef, 'Empty res: is_info');
    is($req->is_redirect(), undef, 'Empty res: is_redirect');
    is($req->is_error(), undef, 'Empty res: is_error');
    is($req->is_client_error(), undef, 'Empty res: is_client_error');
    is($req->is_server_error(), undef, 'Empty res: is_server_error');
    is($req->filename(), undef, 'Empty res: filename');
}

my $time = time;

my $req = HTTP::Request->new(GET => 'http://www.sn.no');
$req->date($time - 30);

my $r = HTTP::Response->new(200, "OK");
$r->client_date($time - 20);
$r->date($time - 25);
$r->last_modified($time - 5000000);
$r->request($req);

#print $r->as_string;

my $current_age = $r->current_age;

ok($current_age >= 35  && $current_age <= 40);

my $freshness_lifetime = $r->freshness_lifetime;
ok($freshness_lifetime >= 12 * 3600);
is($r->freshness_lifetime(heuristic_expiry => 0), undef);

my $is_fresh = $r->is_fresh;
ok($is_fresh);
is($r->is_fresh(heuristic_expiry => 0), undef);

print "# current_age        = $current_age\n";
print "# freshness_lifetime = $freshness_lifetime\n";
print "# response is ";
print " not " unless $is_fresh;
print "fresh\n";

print "# it will be fresh for ";
print $freshness_lifetime - $current_age;
print " more seconds\n";

# OK, now we add an Expires header
$r->expires($time);
print "\n", $r->dump(prefix => "# ");

$freshness_lifetime = $r->freshness_lifetime;
is($freshness_lifetime, 25);
$r->remove_header('expires');

# Now we try the 'Age' header and the Cache-Contol:
$r->header('Age', 300);
$r->push_header('Cache-Control', 'junk');
$r->push_header(Cache_Control => 'max-age = 10');

#print $r->as_string;

$current_age = $r->current_age;
$freshness_lifetime = $r->freshness_lifetime;

print "# current_age        = $current_age\n";
print "# freshness_lifetime = $freshness_lifetime\n";

ok($current_age >= 300);
is($freshness_lifetime, 10);

ok($r->fresh_until);  # should return something
ok($r->fresh_until(heuristic_expiry => 0));  # should return something

my $r2 = HTTP::Response->parse($r->as_string( "\x0d\x0a"));
is( $r2->message(), 'OK', 'message() returns as expected' );

my @h = $r2->header('Cache-Control');
is(@h, 2);

$r->remove_header("Cache-Control");

ok($r->fresh_until);  # should still return something
is($r->fresh_until(heuristic_expiry => 0), undef);

is($r->redirects, 0);
$r->previous($r2);
is($r->previous, $r2);
is($r->redirects, 1);

$r2->previous($r->clone);
is($r->redirects, 2);
for ($r->redirects) {
    ok($_->is_success);
}

is($r->base, $r->request->uri);
$r->push_header("Content-Location", "/1/A/a");
is($r->base, "http://www.sn.no/1/A/a");
$r->push_header("Content-Base", "/2/;a=/foo/bar");
is($r->base, "http://www.sn.no/2/;a=/foo/bar");
$r->push_header("Content-Base", "/3/");
is($r->base, "http://www.sn.no/2/;a=/foo/bar");

{
	my @warn;
	local $SIG{__WARN__} = sub { push @warn, @_ };
	local $^W = 0;
	$r2 = HTTP::Response->parse( undef );
	is($#warn, -1);
	local $^W = 1;
	$r2 = HTTP::Response->parse( undef );
	is($#warn, 0);
	like($warn[0], qr/Undefined argument to parse\(\)/);
}
is($r2->code, undef);
is($r2->message, undef);
is($r2->protocol, undef);
is($r2->status_line, "000 Unknown code");
$r2->protocol('HTTP/1.0');
is($r2->as_string("\n"), "HTTP/1.0 000 Unknown code\n\n");
is($r2->dump, "HTTP/1.0 000 Unknown code\n\n(no content)\n");
is($r2->current_age, 0);
is($r2->freshness_lifetime, 3600);
is($r2->freshness_lifetime(h_default => 900), 900);
is($r2->freshness_lifetime(h_min => 7200), 7200);
is($r2->freshness_lifetime(time => time), 3600);
$r2->last_modified(time - 900);
is($r2->freshness_lifetime, 90);
is($r2->freshness_lifetime(h_lastmod_fraction => 0.2), 180);
is($r2->freshness_lifetime(h_min => 300), 300);
$r2->last_modified(time - 1000000);
is($r2->freshness_lifetime(h_max => 7200), 7200);
is($r2->freshness_lifetime(heuristic_expiry => 0), undef);
is($r2->freshness_lifetime(heuristic_expiry => 1), 86400);
ok($r2->is_fresh(time => time));
ok($r2->fresh_until(time => time + 10));

$r2->client_date(1);
cmp_ok(abs(time - $r2->current_age), '<', 10); # Allow 10s for slow boxes
is($r2->freshness_lifetime, 60);
$r2->date(time);
$r2->header(Age => -1);
cmp_ok(abs(time - $r2->current_age), '<', 10); # Allow 10s for slow boxes
is($r2->freshness_lifetime, 86400);
$req = HTTP::Request->new;
$r2->request($req);
cmp_ok(abs(time - $r2->current_age), '<', 10); # Allow 10s for slow boxes
$req->date(2);
$r2->request($req);
cmp_ok(abs(time - $r2->current_age), '<', 10); # Allow 10s for slow boxes

$r2->header ('Content-Disposition' => "attachment; filename=foo.txt\n");
is($r2->filename(), 'foo.txt');
$r2->header ('Content-Disposition' => "attachment; filename=\n");
is($r2->filename(), '');
$r2->header ('Content-Disposition' => "attachment\n");
is($r2->filename(), undef);
$r2->header ('Content-Disposition' => "attachment; filename==?US-ASCII?B?Zm9vLnR4dA==?=\n");
is($r2->filename(), 'foo.txt');
$r2->header ('Content-Disposition' => "attachment; filename==?NOT-A-CHARSET?B?Zm9vLnR4dA==?=\n");
is($r2->filename(), '=?NOT-A-CHARSET?B?Zm9vLnR4dA==?=');
$r2->header ('Content-Disposition' => "attachment; filename==?US-ASCII?Z?Zm9vLnR4dA==?=\n");
is($r2->filename(), '=?US-ASCII?Z?Zm9vLnR4dA==?=');
$r2->header ('Content-Disposition' => "attachment; filename==?US-ASCII?Q?foo.txt?=\n");
is($r2->filename(), 'foo.txt');
$r2->remove_header ('Content-Disposition');
$r2->header ('Content-Location' => '/tmp/baz.txt');
is($r2->filename(), 'baz.txt');
$r2->remove_header ('Content-Location');
$req->uri('http://www.example.com/bar.txt');
is($r2->filename(), 'bar.txt');
