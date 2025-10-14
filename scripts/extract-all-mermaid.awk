#!/bin/bash

# extract-all-mermaid.awk
# Extrait tous les blocs mermaid d'un fichier Markdown

BEGIN {
    block_count = 0
    in_mermaid = 0
}

/^```mermaid$/ {
    in_mermaid = 1
    block_count++
    print ":::BLOCK_START:::" block_count
    next
}

/^```$/ && in_mermaid {
    in_mermaid = 0
    print ":::BLOCK_END:::"
    next
}

in_mermaid {
    print
}
