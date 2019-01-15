#!/usr/bin/perl -w

use strict;
use warnings;

use Cwd 'realpath';
use File::Temp 'tempfile';
use Test::Needs { 'LWP::UserAgent' => 6.05 };
use Test::More;
use Test::Warnings ':all';

my($tmpfh,$tmpfile) = tempfile(UNLINK => 1);
close $tmpfh;
chmod 0400, $tmpfile or die $!;

my $res = LWP::UserAgent->new->get('file://' . realpath($0), ':content_file' => $tmpfile);
ok $res->header('X-Died'), 'X-Died header seen';
like(warning { $res->is_success }, qr{X\-Died}, 'warning about X-Died header seen.');

done_testing();
