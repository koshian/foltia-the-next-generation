use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Foltia',
    license             => 'perl',
    dist_author         => 'Sugano Yoshihisa(E) <koshian@misao.gr.jp>',
    dist_version_from   => 'lib/Foltia.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'Foltia-*' ],
);

$builder->create_build_script();
