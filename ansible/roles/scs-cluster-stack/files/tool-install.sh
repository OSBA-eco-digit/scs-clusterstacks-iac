#!/bin/sh
scripts=$(ls -1 tool-install-*sh)
for S in $scripts; do
    /bin/sh ${S}
done
