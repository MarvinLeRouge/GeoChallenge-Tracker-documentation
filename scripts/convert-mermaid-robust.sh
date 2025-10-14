#!/bin/bash

# convert-mermaid-robust.sh
# Version robuste avec gestion des séparations

FILE="$1"
IMG_DIR="assets/images"
mkdir -p "$IMG_DIR"

echo "Conversion robuste de: $FILE"
echo "---------------------------"

# Créer une copie de travail
temp_file=$(mktemp)
cp "$FILE" "$temp_file"

# Extraire et convertir chaque bloc séparément
block_count=0
success_count=0

# Trouver tous les blocs mermaid
awk '
BEGIN { block = 0; in_mermaid = 0 }
/^```mermaid$/ {
    in_mermaid = 1
    block++
    print ":::BLOCK_START:::" block
    next
}
/^```$/ && in_mermaid {
    in_mermaid = 0
    print ":::BLOCK_END:::"
    next
}
in_mermaid { print }
' "$temp_file" | while IFS= read -r line; do
    case "$line" in
        :::BLOCK_START:::*)
            block_number=${line#:::BLOCK_START:::}
            current_block=""
            echo "Traitement du diagramme $block_number..."
            ;;
        :::BLOCK_END:::*)
            if [ -n "$current_block" ]; then
                base_name=$(basename "$FILE" .md)
                output_path="${IMG_DIR}/${base_name}-diagram-${block_number}.svg"
                block_file=$(mktemp)
                
                # Écrire le bloc dans un fichier temporaire
                echo "$current_block" > "$block_file"
                
                # Conversion
                if mmdc -i "$block_file" -o "$output_path" --puppeteerConfigFile puppeteer-config.json 2>/dev/null; then
                    echo "✓ Succès: $output_path"
                    ((success_count++))
                    
                    # Remplacer dans le fichier original
                    replacement="![Diagramme ${block_number}](${output_path})"
                    
                    # Remplacer seulement le premier occurrence correspondante
                    sed -i "0,/\\\`\\\`\\\`mermaid/{s/\\\`\\\`\\\`mermaid[^\\\`]*\\\`\\\`\\\`/${replacement}/}" "$temp_file"
                else
                    echo "✗ Échec du diagramme $block_number"
                    echo "Contenu problématique:"
                    echo "$current_block" | head -5
                    echo "..."
                fi
                
                rm -f "$block_file"
            fi
            ;;
        *)
            current_block="${current_block}${line}\n"
            ;;
    esac
    ((block_count++))
done

# Copier le résultat final
if [ $success_count -gt 0 ]; then
    cp "$temp_file" "$FILE"
    echo "✅ Conversion terminée: $success_count/$block_count diagrammes convertis"
else
    echo "❌ Aucun diagramme converti"
fi

rm -f "$temp_file"
