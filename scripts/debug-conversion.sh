#!/bin/bash

# debug-conversion.sh
# Debug précis des erreurs de conversion

FILE="${1:-./FONC_ArchitectureLogicielle_v1.0.md}"
IMG_DIR="assets/images"
mkdir -p "$IMG_DIR"

echo "Debug détaillé de: $FILE"
echo "-----------------------"

# Extraire le premier bloc mermaid pour test
first_block=$(awk '/^```mermaid$/,/^```$/ {if (!/^```/ && !/^```mermaid/) print}' "$FILE" | head -10)

if [ -z "$first_block" ]; then
    echo "Aucun bloc mermaid trouvé!"
    exit 1
fi

echo "Premier bloc mermaid extrait:"
echo "--------------------------------"
echo "$first_block"
echo "--------------------------------"

# Sauvegarder dans un fichier temporaire
temp_file=$(mktemp)
echo "$first_block" > "$temp_file"

echo "Tentative de conversion avec mmdc..."
echo "Fichier temporaire: $temp_file"

# Exécuter mmdc avec debug
mmdc -i "$temp_file" -o debug-test.svg -t default 2>&1

# Vérifier le résultat
if [ $? -eq 0 ]; then
    echo "✓ Conversion réussie!"
    ls -la debug-test.svg
else
    echo "✗ Échec de la conversion"
    echo "Contenu du fichier:"
    cat "$temp_file"
    echo "------------------------"
    echo "Erreur détaillée:"
    mmdc -i "$temp_file" -o debug-test.svg 2>&1
fi

rm -f "$temp_file"
