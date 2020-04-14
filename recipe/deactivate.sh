#!/bin/bash

unset AMBERHOME
if [[ ${_PRE_AMBERTOOLS_PERL5LIBS+x} ]]; then
    export PERL5LIBS=${_PRE_AMBERTOOLS_PERL5LIBS}
    unset _PRE_AMBERTOOLS_PERL5LIBS
else
    unset PERL5LIBS
fi
