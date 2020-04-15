#!/bin/bash

set -e AMBERHOME
if set -q _PRE_AMBERTOOLS_PERL5LIB
    set -gx PERL5LIB "$_PRE_AMBERTOOLS_PERL5LIB"
    set -e _PRE_AMBERTOOLS_PERL5LIB
else
    set -e PERL5LIB
end
