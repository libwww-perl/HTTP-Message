use strict;
use warnings;

use Test::More;
plan tests => 43;

use HTTP::Response;
my $r = HTTP::Response->new(200, "OK");
is($r->content_charset, undef);
is($r->content_type_charset, undef);

$r->content_type("text/plain");
is($r->content_charset, undef);

$r->content("abc");
is($r->content_charset, "US-ASCII");

$r->content("f\xE5rep\xF8lse\n");
is($r->content_charset, "ISO-8859-1");

$r->content("f\xC3\xA5rep\xC3\xB8lse\n");
is($r->content_charset, "UTF-8");

$r->content_type("text/html");
$r->content(<<'EOT');
<meta charset="UTF-8">
EOT
is($r->content_charset, "UTF-8");

$r->content(<<'EOT');
<body>
<META CharSet="Utf-16-LE">
<meta charset="ISO-8859-1">
EOT
is($r->content_charset, "UTF-8");

$r->content(<<'EOT');
<!-- <meta charset="UTF-8">
EOT
is($r->content_charset, "US-ASCII");

$r->content(<<'EOT');
<meta content="text/plain; charset=UTF-8">
EOT
is($r->content_charset, "UTF-8");

$r->content_type('text/plain; charset="iso-8859-1"');
is($r->content_charset, "ISO-8859-1");
is($r->content_type_charset, "ISO-8859-1");

$r->content_type("application/xml");
$r->content("<foo>..</foo>");
is($r->content_charset, "UTF-8");

require Encode;
for my $enc ("UTF-16BE", "UTF-16LE", "UTF-32BE", "UTF-32LE") {
    $r->content(Encode::encode($enc, "<foo>..</foo>"));
    is($r->content_charset, $enc);
}

$r->content(<<'EOT');
<?xml version="1.0" encoding="utf8" ?>
EOT
is($r->content_charset, "utf8");

$r->content(<<'EOT');
<?xml version="1.0" encoding=" "?>
EOT
is($r->content_charset, "UTF-8");

$r->content(<<'EOT');
<?xml version="1.0" encoding="  ISO-8859-1 "?>
EOT
is($r->content_charset, "ISO-8859-1");

$r->content(<<'EOT');
<?xml version="1.0"
encoding="US-ASCII" ?>
EOT
is($r->content_charset, "US-ASCII");

$r->content_type("application/json");
for my $enc ("UTF-8", "UTF-16BE", "UTF-16LE", "UTF-32BE", "UTF-32LE") {
    $r->content(Encode::encode($enc, "{}"));
    is($r->content_charset, $enc);
}

{
 sub TIESCALAR{bless[]}
 tie $_, "";
 my $fail = 0;
 sub STORE{ ++$fail }
 sub FETCH{}
 $r->content_charset;
 is($fail, 0, 'content_charset leaves $_ alone');
}

$r->remove_content_headers;
$r->content_type("text/plain; charset=UTF-8");
$r->content("abc");
is($r->decoded_content, "abc");

$r->content("\xc3\xa5");
is($r->decoded_content, chr(0xE5));
is($r->decoded_content(charset => "none"), "\xC3\xA5");
is($r->decoded_content(alt_charset => "UTF-8"), chr(0xE5));
is($r->decoded_content(alt_charset => "none"), chr(0xE5));

$r->content_type("text/plain; charset=UTF");
is($r->decoded_content, undef);
is($r->decoded_content(charset => "UTF-8"), chr(0xE5));
is($r->decoded_content(charset => "none"), "\xC3\xA5");
is($r->decoded_content(alt_charset => "UTF-8"), chr(0xE5));
is($r->decoded_content(alt_charset => "none"), "\xC3\xA5");

# char semantics for latin-1?
is($r->decoded_content(charset => "iso-8859-1"), "\xC3\xA5");
is(lc($r->decoded_content(charset => "iso-8859-1")), "\xE3\xA5");

$r->content_type("text/plain");
is($r->decoded_content, chr(0xE5));
is($r->decoded_content(charset => "none"), "\xC3\xA5");
is($r->decoded_content(default_charset => "ISO-8859-1"), "\xC3\xA5");
is($r->decoded_content(default_charset => "latin1"), "\xC3\xA5");
