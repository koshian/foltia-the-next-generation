use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Foltia',
    AUTHOR              => 'Sugano Yoshihisa(E) <koshian@misao.gr.jp>',
    VERSION_FROM        => 'lib/Foltia.pm',
    ABSTRACT_FROM       => 'lib/Foltia.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Foltia-*' },
);
