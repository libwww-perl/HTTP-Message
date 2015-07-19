require 5.008001;
use strict;
use warnings;

use ExtUtils::MakeMaker;

my %WriteMakefileArgs = (
    NAME => 'HTTP::Message',
    VERSION_FROM => 'lib/HTTP/Message.pm',
    ABSTRACT => 'HTTP style messages',
    AUTHOR => 'Gisle Aas <gisle@activestate.com>',
    LICENSE => 'perl_5',
    MIN_PERL_VERSION => 5.008001,
    PREREQ_PM => {
        'URI'            => "1.10",
	'HTTP::Date'     => 6,
        'MIME::Base64'   => "2.1",
	'MIME::QuotedPrint' => 0,
	'IO::HTML'       => 0,
	'Encode'         => "2.21", # need mime_name
	'Encode::Locale' => 1,
	'LWP::MediaTypes' => 6,
        'Compress::Raw::Zlib'        => 0,
        'IO::Compress::Gzip'         => 0,
        'IO::Compress::Deflate'      => 0,
        'IO::Compress::Bzip2'        => '2.021',
        'IO::Uncompress::Gunzip'     => 0,
        'IO::Uncompress::Inflate'    => 0,
        'IO::Uncompress::RawInflate' => 0,
        'IO::Uncompress::Bunzip2'    => '2.021',
        'Exporter'                   => '5.57',
    },
    TEST_REQUIRES => {
        'Test::More'                 => '0',
    },

    META_MERGE => {
        'meta-spec' => { version => 2 },
        dynamic_config => 0,
        resources => {
            repository => {
                url => 'https://github.com/libwww-perl/HTTP-Message.git',
                web => 'https://github.com/libwww-perl/HTTP-Message',
                type => 'git',
            },
            bugtracker => {
                mailto => 'bug-HTTP-Message@rt.cpan.org',
                web => 'https://rt.cpan.org/Public/Dist/Display.html?Name=HTTP-Message',
            },
            x_MailingList => 'mailto:libwww@perl.org',
            x_IRC => 'irc://irc.perl.org/#lwp',
        },
    },
);

# compatibility with older versions of MakeMaker
my $developer = -f ".gitignore";

die 'need to do a merge with CPAN::Meta::Requirements!!'
    if $developer && exists $WriteMakefileArgs{BUILD_REQUIRES};

if (!eval { ExtUtils::MakeMaker->VERSION('6.6303') }) {
    $WriteMakefileArgs{BUILD_REQUIRES} = $WriteMakefileArgs{TEST_REQUIRES};
    delete $WriteMakefileArgs{TEST_REQUIRES};
}

if (!eval { ExtUtils::MakeMaker->VERSION('6.5501') }) {
    @{$WriteMakefileArgs{PREREQ_PM}}{ keys %{$WriteMakefileArgs{BUILD_REQUIRES}} } =
        @{$WriteMakefileArgs{BUILD_REQUIRES}}{ keys %{$WriteMakefileArgs{BUILD_REQUIRES}} };

    delete $WriteMakefileArgs{BUILD_REQUIRES};
}

my %mm_req = (
    LICENCE => 6.31,
    META_MERGE => 6.45,
    META_ADD => 6.45,
    MIN_PERL_VERSION => 6.48,
);
for (keys %mm_req) {
    unless (eval { ExtUtils::MakeMaker->VERSION($mm_req{$_}) }) {
        warn "$_ $@" if $developer;
        delete $WriteMakefileArgs{$_};
    }
}

WriteMakefile(%WriteMakefileArgs);
