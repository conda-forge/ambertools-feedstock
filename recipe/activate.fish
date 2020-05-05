#!/bin/bash

set -gx AMBERHOME "$CONDA_PREFIX"
if set -q PERL5LIB
    set -gx _PRE_AMBERTOOLS_PERL5LIB "$PERL5LIB"
    set -gx PERL5LIB "$CONDA_PREFIX/lib/perl/mm_pbsa:$PERL5LIB"
else
    set -gx PERL5LIB "$CONDA_PREFIX/lib/perl/mm_pbsa"
end
