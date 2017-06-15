requires "Carp" => "0";
requires "Compress::Raw::Zlib" => "0";
requires "Encode" => "2.21";
requires "Encode::Locale" => "1";
requires "Exporter" => "5.57";
requires "HTTP::Date" => "6";
requires "IO::Compress::Bzip2" => "2.021";
requires "IO::Compress::Deflate" => "0";
requires "IO::Compress::Gzip" => "0";
requires "IO::HTML" => "0";
requires "IO::Uncompress::Bunzip2" => "2.021";
requires "IO::Uncompress::Gunzip" => "0";
requires "IO::Uncompress::Inflate" => "0";
requires "IO::Uncompress::RawInflate" => "0";
requires "LWP::MediaTypes" => "6";
requires "MIME::Base64" => "2.1";
requires "MIME::QuotedPrint" => "0";
requires "Storable" => "0";
requires "URI" => "1.10";
requires "base" => "0";
requires "perl" => "5.008001";
requires "strict" => "0";
requires "warnings" => "0";

on 'test' => sub {
  requires "ExtUtils::MakeMaker" => "0";
  requires "File::Spec" => "0";
  requires "PerlIO::encoding" => "0";
  requires "Test::More" => "0.88";
  requires "Time::Local" => "0";
  requires "Try::Tiny" => "0";
  requires "perl" => "5.008001";
};

on 'test' => sub {
  recommends "CPAN::Meta" => "2.120900";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
  requires "perl" => "5.006";
};

on 'configure' => sub {
  suggests "JSON::PP" => "2.27300";
};

on 'develop' => sub {
  requires "Test::CPAN::Changes" => "0.19";
  requires "Test::More" => "0.96";
};
