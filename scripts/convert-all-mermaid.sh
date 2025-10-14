#!/bin/bash

# convert-all-mermaid.sh
# Convertit TOUS les blocs mermaid avec awk

FILE="$1"
IMG_DIR="assets/images"
mkdir -p "$IMG_DIR"

echo "Conversion de tous les blocs mermaid de: $FILE"
echo "---------------------------------------------"

# Extraire tous les blocs avec awk
awk -f extract-all-mermaid.awk "$FILE" | while IFS= read -r line; do
    case "$line" in
        :::BLOCK_START:::*)
            block_number="${line#:::BLOCK_START:::}"
            current_block=""
            echo "Traitement du diagramme $block_number..."
            ;;
        :::BLOCK_END:::*)
            if [ -n "$current_block" ]; then
                # Créer fichier temporaire
                temp_file=$(mktemp)
                echo "$current_block" > "$temp_file"
                
                # Convertir
                output_path="${IMG_DIR}/$(basename "$FILE" .md)-diagram-${block_number}.svg"
                
                if mmdc -i "$temp_file" -o "$output_path" --puppeteerConfigFile puppeteer-config.json 2>/dev/null; then
                    echo "✓ Succès: $output_path"
                else
                    echo "✗ Échec du diagramme $block_number"
                    echo "Contenu problématique:"
                    echo "$current_block" | head -5
                    echo "..."
                fi
                
                rm -f "$temp_file"
            fi
            ;;
        *)
            current_block="${current_block}${line}"$'\n'
            ;;
    esac
done

echo "Conversion terminée."
