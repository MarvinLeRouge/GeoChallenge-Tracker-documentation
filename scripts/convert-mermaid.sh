#!/bin/bash

# convert-mermaid.sh - Version simplifiée et fonctionnelle
# Usage: ./convert-mermaid.sh [dossier_racine]

ROOT_DIR="${1:-.}"
IMG_DIR="${ROOT_DIR}/assets/images"
COUNT=0

# Créer le dossier des images (correction du problème #1)
mkdir -p "$IMG_DIR"

echo "Recherche de fichiers Markdown dans: $ROOT_DIR"
echo "----------------------------------------"

# Trouver tous les fichiers .md
find "$ROOT_DIR" -name "*.md" -type f | while read -r file; do
    echo "Traitement de: $file"
    
    # Lire le contenu entier du fichier
    content=$(cat "$file")
    new_content="$content"
    changed=false
    index=0
    
    # Extraire les blocs mermaid avec awk (méthode plus robuste)
    awk '
        /^```mermaid$/ { 
            in_mermaid=1
            print ":::START:::" 
            next
        }
        /^```$/ && in_mermaid { 
            in_mermaid=0
            print ":::END:::"
            next
        }
        in_mermaid { print }
    ' "$file" | while IFS= read -r line; do
        case "$line" in
            ":::START:::")
                current_block=""
                ;;
            ":::END:::")
                if [ -n "$current_block" ]; then
                    ((index++))
                    base_name=$(basename "$file" .md)
                    output_path="${IMG_DIR}/${base_name}-diagram-${index}.svg"
                    
                    # Créer fichier temporaire pour mmdc
                    temp_file=$(mktemp)
                    echo "$current_block" > "$temp_file"
                    
                    if mmdc -i "$temp_file" -o "$output_path" -t default 2>/dev/null; then
                        echo "  ✓ Diagramme $index converti: $output_path"
                        ((COUNT++))
                        
                        # Préparer le remplacement
                        replacement="![${base_name} Diagram](${output_path})"
                        
                        # Remplacer dans le contenu (méthode simple)
                        new_content=$(echo "$new_content" | sed "0,/\`\`\`mermaid\`\`\`/s//$replacement/" | sed "0,/\`\`\`mermaid/,/\`\`\`/s//$replacement/")
                        changed=true
                    else
                        echo "  ✗ Erreur de conversion pour le diagramme $index"
                    fi
                    
                    rm -f "$temp_file"
                    current_block=""
                fi
                ;;
            *)
                if [ -n "$current_block" ]; then
                    current_block="${current_block}\n${line}"
                else
                    current_block="$line"
                fi
                ;;
        esac
    done
    
    # Écrire le nouveau contenu si des changements ont été faits
    if [ "$changed" = true ]; then
        echo "$new_content" > "$file.tmp"
        mv "$file.tmp" "$file"
        echo "  ✓ Fichier mis à jour avec $index diagramme(s)"
    fi
done

echo "----------------------------------------"
echo "Conversion terminée. $COUNT diagramme(s) converti(s)."
