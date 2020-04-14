#!/bin/bash

set -gx AMBERHOME "$CONDA_PREFIX"
if set -q PERL5LIBS
    set -gx _PRE_AMBERTOOLS_PERL5LIBS "$PERL5LIBS"
    set -gx PERL5LIBS "$CONDA_PREFIX/lib/perl/mm_pbsa:$PERL5LIBS"
else
    set -gx PERL5LIBS "$CONDA_PREFIX/lib/perl/mm_pbsa"
end
