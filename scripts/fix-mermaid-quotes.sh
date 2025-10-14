#!/bin/bash

# fix-mermaid-quotes.sh
# Ajoute automatiquement les guillemets aux labels contenant des caractères spéciaux

FILE="$1"

echo "Correction des guillemets dans: $FILE"
echo "------------------------------------"

# Créer une copie temporaire
temp_file=$(mktemp)
cp "$FILE" "$temp_file"

# Fonction pour corriger un bloc Mermaid
fix_mermaid_block() {
    local block="$1"
    
    # 1. Corriger les labels après -->| | et -.->| |
    block=$(echo "$block" | sed -E 's/(-->|-.->)\|([^|"'\'']+)\|/\1|"\2"|/g')
    
    # 2. Corriger les labels dans les nodes [ ]
    block=$(echo "$block" | sed -E 's/\[([^]["]+)\]/["\1"]/g')
    
    # 3. Corriger les labels avec des parenthèses ( )
    block=$(echo "$block" | sed -E 's/\(([^)("]+)\)/("\1")/g')
    
    # 4. Corriger les liens --> sans | |
    block=$(echo "$block" | sed -E 's/(-->|-.->)([^[:space:]|][^[:space:]]*[^[:space:]|])/\1"\2"/g')
    
    echo "$block"
}

# Traiter le fichier
in_mermaid=false
current_block=""
output_content=""
block_number=0

while IFS= read -r line; do
    if [[ "$line" == '```mermaid' ]]; then
        in_mermaid=true
        current_block=""
        output_content="${output_content}${line}"$'\n'
        continue
    fi
    
    if [[ "$line" == '```' && "$in_mermaid" == true ]]; then
        in_mermaid=false
        ((block_number++))
        
        echo "Correction du diagramme $block_number..."
        corrected_block=$(fix_mermaid_block "$current_block")
        
        output_content="${output_content}${corrected_block}"$'\n'
        output_content="${output_content}${line}"$'\n'
        
        current_block=""
        continue
    fi
    
    if [ "$in_mermaid" = true ]; then
        current_block="${current_block}${line}"$'\n'
    else
        output_content="${output_content}${line}"$'\n'
    fi
done < "$temp_file"

# Écrire le résultat
echo "$output_content" > "$FILE"
rm -f "$temp_file"

echo "Correction terminée. $block_number diagramme(s) traité(s)."
