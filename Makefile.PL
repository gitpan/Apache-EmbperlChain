use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Apache::EmbperlChain',
    'VERSION_FROM' => 'EmbperlChain.pm', # finds $VERSION
    'PREREQ_PM' => {'HTML::Embperl' => 1.0,
                    'Apache::OutputChain' => 0.0 },
     dist => {
               SUFFIX => 'gz',
               COMPRESS => 'gzip -9',
             }
);
