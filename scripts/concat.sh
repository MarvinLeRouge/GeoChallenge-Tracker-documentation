#!/bin/bash

# Script pour concaténer et convertir les fichiers Markdown en PDF
# Usage: ./generate-pdf.sh

set -e  # Arrêter en cas d'erreur

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
OUTPUT_FILE="00-dossier-projet.md"
CONFIG_FILE="scripts/md-to-pdf-config.js"
STYLESHEET="scripts/markdown-pdf-styles.css"
PDF_OUTPUT="${OUTPUT_FILE%.md}.pdf"

echo -e "${BLUE}=== Génération du PDF du projet ===${NC}"

# Vérifier que les fichiers de configuration existent
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo -e "${RED}Erreur: Fichier de configuration non trouvé: $CONFIG_FILE${NC}"
    exit 1
fi

if [[ ! -f "$STYLESHEET" ]]; then
    echo -e "${YELLOW}Attention: Fichier de styles non trouvé: $STYLESHEET${NC}"
    echo -e "${YELLOW}Continuing without stylesheet...${NC}"
    STYLESHEET=""
fi

# Fonction pour extraire le numéro au début du nom de fichier
extract_number() {
    echo "$1" | grep -oE '^[0-9]+' | sed 's/^0*//'
}

# Étape 1: Lister et trier les fichiers .md qui commencent par un nombre
echo -e "${BLUE}Étape 1: Recherche des fichiers Markdown...${NC}"

# Créer un tableau associatif temporaire pour le tri
declare -A files_with_numbers
md_files=()

for file in [0-9]*.md; do
    # Vérifier que le fichier existe (éviter les globs non résolus)
    if [[ -f "$file" ]]; then
        number=$(extract_number "$file")
        # Utiliser le numéro comme clé pour le tri
        files_with_numbers["$number"]="$file"
        echo -e "${GREEN}  Trouvé: $file (numéro: $number)${NC}"
    fi
done

# Vérifier qu'on a trouvé des fichiers
if [[ ${#files_with_numbers[@]} -eq 0 ]]; then
    echo -e "${RED}Aucun fichier .md commençant par un nombre trouvé dans le dossier courant.${NC}"
    exit 1
fi

# Trier les clés numériquement et construire le tableau ordonné
IFS=$'\n' sorted_numbers=($(printf '%s\n' "${!files_with_numbers[@]}" | sort -n))

echo -e "${BLUE}Ordre de concaténation:${NC}"
for num in "${sorted_numbers[@]}"; do
    file="${files_with_numbers[$num]}"
    md_files+=("$file")
    echo -e "${GREEN}  $num. $file${NC}"
done

# Étape 2: Concaténation des fichiers
echo -e "${BLUE}Étape 2: Concaténation dans $OUTPUT_FILE...${NC}"

# Supprimer le fichier de sortie s'il existe
[[ -f "$OUTPUT_FILE" ]] && rm "$OUTPUT_FILE"

# En-tête du document avec TOC
cat >> "$OUTPUT_FILE" << 'EOF'
---
title: "Documentation Projet"
date: "$(date '+%d/%m/%Y')"
author: "Équipe Projet"
---

# Table des matières {.no-counter}

<div class="toc">

EOF

# Générer la TOC automatiquement avec meilleure mise en forme
echo -e "${BLUE}  Génération de la table des matières...${NC}"
for file in "${md_files[@]}"; do
    echo -e "${GREEN}    Analyse de $file...${NC}"
    # Extraire et formatter les titres
    while IFS= read -r line; do
        if [[ "$line" =~ ^#[[:space:]] ]]; then
            # H1
            title=$(echo "$line" | sed 's/^#[[:space:]]*//')
            echo "<div class=\"level-1\">$title <span class=\"page-number\">•••</span></div>" >> "$OUTPUT_FILE"
        elif [[ "$line" =~ ^##[[:space:]] ]]; then
            # H2
            title=$(echo "$line" | sed 's/^##[[:space:]]*//')
            echo "<div class=\"level-2\">$title <span class=\"page-number\">•••</span></div>" >> "$OUTPUT_FILE"
        elif [[ "$line" =~ ^###[[:space:]] ]]; then
            # H3
            title=$(echo "$line" | sed 's/^###[[:space:]]*//')
            echo "<div class=\"level-3\">$title <span class=\"page-number\">•••</span></div>" >> "$OUTPUT_FILE"
        fi
    done < "$file"
done

cat >> "$OUTPUT_FILE" << 'EOF'

</div>

<div class="page-break-after"></div>

EOF

# Concaténer les fichiers dans l'ordre
for file in "${md_files[@]}"; do
    echo -e "${GREEN}  Ajout de $file...${NC}"
    
    # Ajouter un séparateur de page avant chaque fichier (sauf le premier)
    if [[ "$file" != "${md_files[0]}" ]]; then
        echo -e "\n\n<div class=\"page-break-before\"></div>\n" >> "$OUTPUT_FILE"
    fi
    
    # Ajouter le contenu du fichier
    cat "$file" >> "$OUTPUT_FILE"
    
    # Ajouter des sauts de ligne entre les fichiers
    echo -e "\n" >> "$OUTPUT_FILE"
done

echo -e "${GREEN}Concaténation terminée: $OUTPUT_FILE ($(wc -l < "$OUTPUT_FILE") lignes)${NC}"

# Étape 3: Conversion en PDF
echo -e "${BLUE}Étape 3: Conversion en PDF...${NC}"

# Construire la commande md-to-pdf
MD_TO_PDF_CMD="md-to-pdf \"$OUTPUT_FILE\" --config-file \"$CONFIG_FILE\""

# Ajouter le stylesheet s'il existe
if [[ -n "$STYLESHEET" ]]; then
    MD_TO_PDF_CMD="$MD_TO_PDF_CMD --stylesheet \"$STYLESHEET\""
fi

echo -e "${BLUE}Commande: $MD_TO_PDF_CMD${NC}"

# Exécuter la conversion
if eval $MD_TO_PDF_CMD; then
    echo -e "${GREEN}✅ PDF généré avec succès: $PDF_OUTPUT${NC}"
    
    # Afficher les statistiques du fichier PDF
    if [[ -f "$PDF_OUTPUT" ]]; then
        file_size=$(du -h "$PDF_OUTPUT" | cut -f1)
        echo -e "${GREEN}   Taille du fichier: $file_size${NC}"
    fi
    
    # Nettoyer le fichier temporaire (optionnel)
    read -p "Supprimer le fichier temporaire $OUTPUT_FILE ? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm "$OUTPUT_FILE"
        echo -e "${YELLOW}Fichier temporaire supprimé.${NC}"
    fi
    
else
    echo -e "${RED}❌ Erreur lors de la conversion PDF${NC}"
    echo -e "${YELLOW}Le fichier $OUTPUT_FILE a été conservé pour diagnostic.${NC}"
    exit 1
fi

echo -e "${GREEN}=== Génération terminée avec succès ===${NC}"
