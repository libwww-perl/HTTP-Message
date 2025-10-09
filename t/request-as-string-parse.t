#!/usr/bin/perl
# Test that as_string and parse are commutative for HTTP::Request (issue #62959)

use strict;
use warnings;

use Test::More tests => 9;

use HTTP::Request;

# Test 1: Request with content (no trailing newline)
{
    my $r = HTTP::Request->new(POST => 'http://example.com/');
    $r->content("This is request content");
    my $original_content = $r->content;
    
    my $s = $r->as_string;
    my $t = HTTP::Request->parse($s);
    
    is($t->content, $original_content, 
       'Content without trailing newline preserved through as_string/parse');
}

# Test 2: Request with content ending in newline
{
    my $r = HTTP::Request->new(POST => 'http://example.com/');
    $r->content("Content with newline\n");
    my $original_content = $r->content;
    
    my $s = $r->as_string;
    my $t = HTTP::Request->parse($s);
    
    is($t->content, $original_content,
       'Content with trailing newline preserved through as_string/parse');
}

# Test 3: Request with multiline content
{
    my $r = HTTP::Request->new(POST => 'http://example.com/');
    $r->content("Line 1\nLine 2\nLine 3");
    my $original_content = $r->content;
    
    my $s = $r->as_string;
    my $t = HTTP::Request->parse($s);
    
    is($t->content, $original_content,
       'Multiline content without trailing newline preserved');
}

# Test 4: Request with empty content
{
    my $r = HTTP::Request->new(GET => 'http://example.com/');
    $r->content("");
    my $original_content = $r->content;
    
    my $s = $r->as_string;
    my $t = HTTP::Request->parse($s);
    
    is($t->content, $original_content,
       'Empty content preserved through as_string/parse');
}

# Test 5: Request with method and URI
{
    my $r = HTTP::Request->new(POST => 'http://example.com/path');
    $r->content("Test content");
    my $original_content = $r->content;
    my $original_uri = $r->uri->as_string;
    
    my $s = $r->as_string;
    my $t = HTTP::Request->parse($s);
    
    is($t->content, $original_content,
       'Content preserved with method and URI');
    is($t->uri->as_string, $original_uri, 'URI preserved');
    is($t->method, 'POST', 'Method preserved');
}

# Test 6: Request with explicit \r\n line endings
{
    my $r = HTTP::Request->new(GET => 'http://example.com/');
    $r->content("Test content");
    my $original_content = $r->content;
    
    my $s = $r->as_string("\r\n");
    my $t = HTTP::Request->parse($s);
    
    is($t->content, $original_content,
       'Content preserved with explicit CRLF line endings');
}

# Test 7: Multiple round trips
{
    my $r = HTTP::Request->new(POST => 'http://example.com/');
    $r->content("Round trip test");
    my $original_content = $r->content;
    
    # First round trip
    my $s1 = $r->as_string;
    my $t1 = HTTP::Request->parse($s1);
    
    # Second round trip
    my $s2 = $t1->as_string;
    my $t2 = HTTP::Request->parse($s2);
    
    is($t2->content, $original_content,
       'Content preserved through multiple round trips');
}
