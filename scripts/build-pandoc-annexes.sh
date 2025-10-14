#!/usr/bin/env bash
# scripts/build-pandoc.sh
# Pipeline SANS MODIFIER LES SOURCES :
#  - Sélectionne uniquement NN-*.md (01-, 02-, …) depuis documents/
#  - Rend les blocs ```mermaid``` (option --render-mermaid) en PNG + légendes
#  - Écrit les .md transformés dans un dossier temporaire (par défaut: build-temp/)
#  - Concatène CES .md traités, retire la numérotation "en dur" (hors blocs code),
#    insère \clearpage avant chaque H1 (hors blocs code)
#  - Génère le PDF (XeLaTeX) avec header scripts/pandoc-pdf-header.tex
#
# Usage (depuis documents/):
#   scripts/build-pandoc.sh --toc-depth 3 --render-mermaid
#
# Options:
#   --toc-depth N           Profondeur de TOC (def: 3)
#   --out-basename NAME     Base du nom de sortie (def: Dossier-projet-annexes)
#   --engine NAME           Moteur LaTeX (def: xelatex)
#   --render-mermaid        Active le rendu des blocs Mermaid (mmdc requis)
#   --temp-dir DIR          Dossier de sortie des .md traités (def: build-temp)
#   --keep-temp             Ne pas nettoyer/écraser le dossier temporaire au début
#   -h | --help             Affiche cette aide
set -Eeuo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[0;33m'; NC='\033[0m'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
DOCS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"     # documents/
HEADER_TEX="$SCRIPT_DIR/pandoc-pdf-header.tex"

OUT_BASENAME="${OUT_BASENAME:-Dossier-projet-annexes}"
OUT_MD="${OUT_BASENAME}.md"
OUT_PDF="${OUT_BASENAME}.pdf"
TOC_DEPTH="${TOC_DEPTH:-3}"
PDF_ENGINE="${PDF_ENGINE:-xelatex}"
RENDER_MERMAID=true
TEMP_DIR="${TEMP_DIR:-build-temp}"
KEEP_TEMP=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --toc-depth) TOC_DEPTH="${2:-3}"; shift 2;;
    --out-basename) OUT_BASENAME="${2:-Dossier-projet-annexes}"; OUT_MD="${OUT_BASENAME}.md"; OUT_PDF="${OUT_BASENAME}.pdf"; shift 2;;
    --engine) PDF_ENGINE="${2:-xelatex}"; shift 2;;
    --render-mermaid) RENDER_MERMAID=true; shift;;
    --temp-dir) TEMP_DIR="${2:-build-temp}"; shift 2;;
    --keep-temp) KEEP_TEMP=true; shift;;
    -h|--help) sed -n '1,200p' "$0"; exit 0;;
    *) echo -e "${YELLOW}Argument inconnu: $1${NC}"; exit 2;;
  esac
done

cd "$DOCS_DIR"
command -v pandoc >/dev/null 2>&1 || { echo -e "${RED}pandoc introuvable.${NC}"; exit 1; }
[[ -f "$HEADER_TEX" ]] || { echo -e "${RED}Header LaTeX introuvable: $HEADER_TEX${NC}"; exit 1; }

# Prépare le dossier temporaire (sources intactes)
if $KEEP_TEMP; then
  mkdir -p "$TEMP_DIR"
else
  rm -rf -- "$TEMP_DIR"
  mkdir -p "$TEMP_DIR"
fi

ASSETS_DIR="$TEMP_DIR/assets/mermaid"
mkdir -p "$ASSETS_DIR"

# Variables pour les fichiers spéciaux
PAGE_DE_GARDE="$DOCS_DIR/00_PageDeGarde_Annexes.tex"
BEFORE_BODY_FILES=""
# Vérifier si on a une page de garde LaTeX
if [[ -f "$PAGE_DE_GARDE" ]]; then
  BEFORE_BODY_FILES="--include-before-body=$PAGE_DE_GARDE"
fi

# --- Sélection: UNIQUEMENT NN-*.md (01-, 02-, …) à la racine de documents/.
mapfile -t SRC_FILES < <(
  find . -maxdepth 1 -type f -regextype posix-extended \
    -regex '^./annexes-[0-9]{2}[^/]*\.md$' \
    -printf '%f\n' | sort -V
)
[[ ${#SRC_FILES[@]} -gt 0 ]] || { echo -e "${RED}Aucun fichier NN-*.md trouvé.${NC}"; exit 1; }

echo -e "${BLUE}==> Traitement vers ${TEMP_DIR}/ (sources intactes)${NC}"

render_or_copy_md() {
  local SRC="$1"                 # ex: 01-...md (dans DOCS_DIR)
  local DST="$TEMP_DIR/$SRC"     # même nom de fichier, dans TEMP_DIR
  if $RENDER_MERMAID; then
    if ! command -v mmdc >/dev/null 2>&1; then
      echo -e "${YELLOW}mmdc non trouvé — je copie ${SRC} sans rendu Mermaid.${NC}"
      cp -f -- "$SRC" "$DST"
      return
    fi
    python3 - "$SRC" "$DST" "$ASSETS_DIR" <<'PYCODE'
import sys, re, subprocess, pathlib, tempfile

src = pathlib.Path(sys.argv[1])
dst = pathlib.Path(sys.argv[2])
assets_dir = pathlib.Path(sys.argv[3])
txt = src.read_text(encoding="utf-8")

# Blocs mermaid fenced (``` ou ~~~), même si indentés
pat = re.compile(r"(^[ \t]*(```|~~~)mermaid\s*\n)(.*?)(\n^[ \t]*\2\s*$)", re.DOTALL | re.MULTILINE)
caption_rx = re.compile(r'^\s*%%\s*(?:caption|title|titre|legend)\s*:\s*(.+)$', re.I)

def latex_escape(s: str) -> str:
    # échappe quelques caractères LaTeX dans les légendes
    return (s.replace('\\', r'\textbackslash{}')
             .replace('&', r'\&').replace('%', r'\%').replace('$', r'\$')
             .replace('#', r'\#').replace('_', r'\_').replace('{', r'\{')
             .replace('}', r'\}').replace('~', r'\textasciitilde{}')
             .replace('^', r'\textasciicircum{}'))

base = src.stem
idx = 1
out = []
last = 0

def render_mermaid(diag_text: str, png_path: pathlib.Path):
    with tempfile.NamedTemporaryFile("w", suffix=".mmd", delete=False, encoding="utf-8") as f:
        f.write(diag_text)
        tmp = pathlib.Path(f.name)
    try:
        subprocess.run(
            ["mmdc", "-i", str(tmp), "-o", str(png_path),
             "--backgroundColor", "transparent", "-w", "3200"],
            check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        )
    finally:
        try: tmp.unlink()
        except FileNotFoundError: pass

for m in pat.finditer(txt):
    out.append(txt[last:m.start()])
    code = m.group(3).strip()
    caption = ""
    lines = code.splitlines()
    if lines:
        mcap = caption_rx.match(lines[0])
        if mcap:
            caption = latex_escape(mcap.group(1).strip())
            code = "\n".join(lines[1:]).lstrip()
    png = assets_dir / f"{base}-mmd-{idx:03d}.png"
    render_mermaid(code, png)
    # Insert un VRAI environnement LaTeX figure ancré [H], avec lignes vides AVANT/APRÈS
    if caption:
        frag = (
            "\n\\begin{figure}[H]\n\\centering\n"
            f"\\includegraphics[width=\\linewidth]{{{png.as_posix()}}}\n"
            f"\\caption{{{caption}}}\n"
            "\\end{figure}\n\n"
        )
    else:
        frag = (
            "\n\\begin{figure}[H]\n\\centering\n"
            f"\\includegraphics[width=\\linewidth]{{{png.as_posix()}}}\n"
            "\\end{figure}\n\n"
        )
    out.append(frag)
    idx += 1
    last = m.end()

out.append(txt[last:])
dst.write_text("".join(out), encoding="utf-8")
PYCODE
  else
    cp -f -- "$SRC" "$DST"
  fi
}

# Transforme tous les fichiers sources vers TEMP_DIR
for f in "${SRC_FILES[@]}"; do
  render_or_copy_md "$f"
done

# Fichiers traités
mapfile -t TMP_FILES < <( printf '%s\n' "${SRC_FILES[@]}" | sed -E "s|^|$TEMP_DIR/|" )

echo -e "${BLUE}==> Concaténation depuis ${TEMP_DIR}/ (${#TMP_FILES[@]} fichiers)${NC}"
TMP_CONCAT="$TEMP_DIR/.tmp_concat_$$.md"
{
  echo "<!-- Fichier généré automatiquement. Ne pas éditer. -->"
  for f in "${TMP_FILES[@]}"; do
    echo; echo "<!-- ===== ${f##*/} ===== -->"; echo
    cat -- "$f"; echo
  done
} > "$TMP_CONCAT"
mv -f -- "$TMP_CONCAT" "$TEMP_DIR/$OUT_MD"
echo -e "${GREEN}✔ Concat → ${TEMP_DIR}/${OUT_MD}${NC}"

# --- Retire la numérotation “en dur” des titres (hors blocs code ```/~~~ indentés)
python3 - "$TEMP_DIR/$OUT_MD" <<'PYCODE'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1])
t = p.read_text(encoding="utf-8")
out = []
in_fence = False
fence_rx = re.compile(r'^[ \t]*(```|~~~)')  # ouverture/fermeture, même si indentés
hdr_rx = re.compile(r'^([ \t]*#{1,6}\s+)(\d+(?:\.\d+)*\.?)\s+(.*)$')
for line in t.splitlines(True):
    if fence_rx.match(line):
        in_fence = not in_fence
        out.append(line); continue
    if not in_fence:
        m = hdr_rx.match(line)
        if m:
            line = f"{m.group(1)}{m.group(3)}\n"
    out.append(line)
p.write_text("".join(out), encoding="utf-8")
PYCODE
echo -e "${GREEN}✔ Numérotation en dur retirée (concaténé, hors blocs code)${NC}"

# --- Convertit des marqueurs HTML en \clearpage (hors blocs de code)
python3 - "$TEMP_DIR/$OUT_MD" <<'PYCODE'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1])
t = p.read_text(encoding="utf-8")

# Nous voulons transformer :
#   <!-- \clearpage -->
#   <!-- clearpage -->
#   <!-- pagebreak -->
#   <!-- newpage -->
# …en LaTeX brut : \clearpage
marker = re.compile(r'<!--\s*(?:\\?clearpage|pagebreak|newpage)\s*-->', re.I)

out = []
in_fence = False
fence_rx = re.compile(r'^[ \t]*(```|~~~)')  # ouvre/ferme un bloc code, même indenté

for line in t.splitlines(True):
    if fence_rx.match(line):
        in_fence = not in_fence
        out.append(line)
        continue
    if not in_fence and marker.search(line):
        # On remplace L'ENTIÈRE ligne par un \clearpage entouré de lignes vides
        out.append("\n\\clearpage\n\n")
    else:
        out.append(line)

p.write_text("".join(out), encoding="utf-8")
PYCODE
echo -e "${GREEN}✔ Marqueurs <!-- clearpage --> convertis en \\clearpage (hors blocs code)${NC}"

# --- Insère \clearpage AVANT CHAQUE H1 (hors blocs code), avec lignes vides autour
python3 - "$TEMP_DIR/$OUT_MD" <<'PYCODE'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1])
t = p.read_text(encoding="utf-8")
out = []
in_fence = False
fence_rx = re.compile(r'^[ \t]*(```|~~~)')
for line in t.splitlines(True):
    if fence_rx.match(line):
        in_fence = not in_fence
        out.append(line); continue
    if (not in_fence) and line.lstrip().startswith("# "):  # H1 réel
        out.append("\n\\clearpage\n\n")
    out.append(line)
p.write_text("".join(out), encoding="utf-8")
PYCODE
echo -e "${GREEN}✔ \\clearpage inséré avant chaque H1 (concaténé, hors blocs code)${NC}"

# --- Génération PDF
echo -e "${BLUE}==> PDF (${PDF_ENGINE}) avec header: ${HEADER_TEX}${NC}"
pandoc "$TEMP_DIR/$OUT_MD" -o "$OUT_PDF" \
  --from=markdown+link_attributes+implicit_figures+tex_math_dollars \
  --toc --toc-depth="${TOC_DEPTH}" \
  --number-sections -V secnumdepth="${TOC_DEPTH}" \
  -V toc-title="Table des matières" -V toc-own-page \
  -V colorlinks=true \
  -V linkcolor=accent \
  -V urlcolor=accent \
  -V citecolor=accent \
  --listings \
  --pdf-engine="${PDF_ENGINE}" \
  --include-in-header "${HEADER_TEX}" \
  ${BEFORE_BODY_FILES}

echo -e "${GREEN}✔ PDF généré: ${OUT_PDF}${NC}"
echo -e "${BLUE}i${NC} Sources intactes. Fichiers traités: ${TEMP_DIR}/  |  Images Mermaid: ${ASSETS_DIR}/"
