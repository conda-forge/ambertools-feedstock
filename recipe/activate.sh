#!/bin/bash

export AMBERHOME=${CONDA_PREFIX}
if [[ ${PERL5LIB+x} ]]; then
    export _PRE_AMBERTOOLS_PERL5LIB=${PERL5LIB}
    export PERL5LIB="${CONDA_PREFIX}/lib/perl/mm_pbsa:${PERL5LIB}"
else
    export PERL5LIB="${CONDA_PREFIX}/lib/perl/mm_pbsa"
fi
