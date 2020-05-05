#!/bin/bash

unset AMBERHOME
if [[ ${_PRE_AMBERTOOLS_PERL5LIB+x} ]]; then
    export PERL5LIB=${_PRE_AMBERTOOLS_PERL5LIB}
    unset _PRE_AMBERTOOLS_PERL5LIB
else
    unset PERL5LIB
fi
