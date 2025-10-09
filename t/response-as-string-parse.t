#!/usr/bin/perl
# Test that as_string and parse are commutative (issue #62959)

use strict;
use warnings;

use Test::More tests => 9;

use HTTP::Response;

# Test 1: Response with content (no trailing newline)
{
    my $r = HTTP::Response->new;
    $r->content("This is a sample of content");
    my $original_content = $r->content;
    
    my $s = $r->as_string;
    my $t = HTTP::Response->parse($s);
    
    is($t->content, $original_content, 
       'Content without trailing newline preserved through as_string/parse');
}

# Test 2: Response with content ending in newline
{
    my $r = HTTP::Response->new;
    $r->content("Content with newline\n");
    my $original_content = $r->content;
    
    my $s = $r->as_string;
    my $t = HTTP::Response->parse($s);
    
    is($t->content, $original_content,
       'Content with trailing newline preserved through as_string/parse');
}

# Test 3: Response with multiline content
{
    my $r = HTTP::Response->new;
    $r->content("Line 1\nLine 2\nLine 3");
    my $original_content = $r->content;
    
    my $s = $r->as_string;
    my $t = HTTP::Response->parse($s);
    
    is($t->content, $original_content,
       'Multiline content without trailing newline preserved');
}

# Test 4: Response with empty content
{
    my $r = HTTP::Response->new;
    $r->content("");
    my $original_content = $r->content;
    
    my $s = $r->as_string;
    my $t = HTTP::Response->parse($s);
    
    is($t->content, $original_content,
       'Empty content preserved through as_string/parse');
}

# Test 5: Response with code and message
{
    my $r = HTTP::Response->new(200, "OK");
    $r->content("Test content");
    my $original_content = $r->content;
    
    my $s = $r->as_string;
    my $t = HTTP::Response->parse($s);
    
    is($t->content, $original_content,
       'Content preserved with status code and message');
    is($t->code, 200, 'Status code preserved');
    is($t->message, 'OK', 'Status message preserved');
}

# Test 6: Response with explicit \r\n line endings
{
    my $r = HTTP::Response->new(200, "OK");
    $r->content("Test content");
    my $original_content = $r->content;
    
    my $s = $r->as_string("\r\n");
    my $t = HTTP::Response->parse($s);
    
    is($t->content, $original_content,
       'Content preserved with explicit CRLF line endings');
}

# Test 7: Multiple round trips
{
    my $r = HTTP::Response->new(200, "OK");
    $r->content("Round trip test");
    my $original_content = $r->content;
    
    # First round trip
    my $s1 = $r->as_string;
    my $t1 = HTTP::Response->parse($s1);
    
    # Second round trip
    my $s2 = $t1->as_string;
    my $t2 = HTTP::Response->parse($s2);
    
    is($t2->content, $original_content,
       'Content preserved through multiple round trips');
}
