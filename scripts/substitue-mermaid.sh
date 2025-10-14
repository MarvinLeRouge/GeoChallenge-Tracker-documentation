#!/bin/bash

# substitute-mermaid.sh
# Extrait, convertit ET remplace les blocs mermaid par les images SVG

FILE="$1"
IMG_DIR="assets/images"
mkdir -p "$IMG_DIR"

echo "Substitution des blocs mermaid dans: $FILE"
echo "-----------------------------------------"

# Créer une copie temporaire pour travailler
temp_file=$(mktemp)
cp "$FILE" "$temp_file"

# Compter les blocs initiaux
initial_blocks=$(grep -c '^```mermaid$' "$temp_file")
echo "Blocs mermaid trouvés: $initial_blocks"

# Fonction pour échapper les caractères spéciaux pour sed
escape_sed() {
    echo "$1" | sed -e 's/[\/&]/\\&/g' | sed -e ':a;N;$!ba;s/\n/\\n/g'
}

# Traiter chaque bloc
block_number=0
while IFS= read -r line; do
    if [[ "$line" == '```mermaid' ]]; then
        ((block_number++))
        in_mermaid=true
        mermaid_content=""
        echo "Traitement du bloc $block_number..."
        continue
    fi

    if [[ "$line" == '```' && "$in_mermaid" == true ]]; then
        in_mermaid=false
        
        # Créer fichier temporaire pour la conversion
        block_file=$(mktemp)
        echo "$mermaid_content" > "$block_file"
        
        # Générer le SVG
        base_name=$(basename "$FILE" .md)
        output_path="${IMG_DIR}/${base_name}-diagram-${block_number}.svg"
        
        if mmdc -i "$block_file" -o "$output_path" --puppeteerConfigFile puppeteer-config.json 2>/dev/null; then
            echo "✓ SVG généré: $output_path"
            
            # Préparer le texte de remplacement
            replacement="![Diagramme ${block_number}](${output_path})"
            
            # Échapper le contenu mermaid pour sed
            escaped_block=$(escape_sed "$mermaid_content")
            
            # Remplacer dans le fichier temporaire
            sed -i ":a;N;\$!ba;s/\`\`\`mermaid${escaped_block}\`\`\`/${replacement}/g" "$temp_file"
            
        else
            echo "✗ Échec conversion bloc $block_number"
        fi
        
        rm -f "$block_file"
        continue
    fi

    if [ "$in_mermaid" = true ]; then
        mermaid_content="${mermaid_content}${line}\n"
    fi

done < "$FILE"

# Vérifier le résultat
final_blocks=$(grep -c '^```mermaid$' "$temp_file")
echo "Blocs mermaid restants: $final_blocks"

if [ $final_blocks -eq 0 ]; then
    echo "✅ Tous les blocs ont été substitués!"
    # Remplacer le fichier original
    cp "$temp_file" "$FILE"
else
    echo "⚠️  Il reste des blocs non traités"
fi

rm -f "$temp_file"
