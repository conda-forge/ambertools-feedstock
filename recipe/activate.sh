#!/bin/bash

export AMBERHOME=${CONDA_PREFIX}
if [[ ${PERL5LIBS+x} ]]; then
    export _PRE_AMBERTOOLS_PERL5LIBS=${PERL5LIBS}
    export PERL5LIBS="${CONDA_PREFIX}/lib/perl/mm_pbsa:${PERL5LIBS}"
else
    export PERL5LIBS="${CONDA_PREFIX}/lib/perl/mm_pbsa"
fi
