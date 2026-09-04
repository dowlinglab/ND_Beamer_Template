#!/usr/bin/env bash
# Regression test runner for the Notre Dame Beamer theme.
# See TESTING.md at the repo root for what this does and how to use it.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CASES_DIR="$SCRIPT_DIR/cases"
BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/nd-beamer-regression.XXXXXX")"

PASS=0
FAIL=0
FAILED_NAMES=()

compile() {
  # compile <name> <tex-file>; runs two passes from the repo root so
  # relative asset paths (logos/..., beamerthemeNotreDame.sty) resolve.
  local name="$1" tex="$2"
  ( cd "$REPO_ROOT" && \
    pdflatex -interaction=nonstopmode -halt-on-error \
      -output-directory="$BUILD_DIR" "$tex" > "$BUILD_DIR/$name.log1" 2>&1 && \
    pdflatex -interaction=nonstopmode -halt-on-error \
      -output-directory="$BUILD_DIR" "$tex" > "$BUILD_DIR/$name.log2" 2>&1 )
}

check_result() {
  # check_result <pdf-path> <log-path>. A real LaTeX error always
  # starts a log line with "!" -- more reliable than grepping for the
  # word "error", which also matches plenty of benign package
  # messages.
  local pdf="$1" log="$2"
  if [ ! -s "$pdf" ]; then
    return 1
  fi
  if grep -q '^!' "$log" 2>/dev/null; then
    return 1
  fi
  return 0
}

echo "Build directory: $BUILD_DIR"
echo

for tex in "$CASES_DIR"/*.tex; do
  name="$(basename "$tex" .tex)"
  printf '%-55s' "$name"
  compile "$name" "$tex"
  if check_result "$BUILD_DIR/$name.pdf" "$BUILD_DIR/$name.log2"; then
    echo "PASS"
    PASS=$((PASS + 1))
  else
    echo "FAIL"
    FAIL=$((FAIL + 1))
    FAILED_NAMES+=("$name")
  fi
done

# Also build the bundled demo itself (main.tex + document.tex), with
# biber, as an end-to-end smoke test beyond the isolated option cases.
# -jobname keeps every output file named main_demo.* regardless of the
# input file's own basename (main.tex), so biber and check_result
# below can address one consistent name.
printf '%-55s' "main_demo (bundled demo, with biber)"
(
  cd "$REPO_ROOT" && \
  pdflatex -interaction=nonstopmode -output-directory="$BUILD_DIR" \
    -jobname=main_demo main.tex > "$BUILD_DIR/main_demo.log1" 2>&1 && \
  biber --input-directory "$BUILD_DIR" --output-directory "$BUILD_DIR" main_demo \
    > "$BUILD_DIR/main_demo.biberlog" 2>&1 && \
  pdflatex -interaction=nonstopmode -output-directory="$BUILD_DIR" \
    -jobname=main_demo main.tex > "$BUILD_DIR/main_demo.log2" 2>&1 && \
  pdflatex -interaction=nonstopmode -output-directory="$BUILD_DIR" \
    -jobname=main_demo main.tex > "$BUILD_DIR/main_demo.log3" 2>&1
)
if check_result "$BUILD_DIR/main_demo.pdf" "$BUILD_DIR/main_demo.log3"; then
  echo "PASS"
  PASS=$((PASS + 1))
else
  echo "FAIL"
  FAIL=$((FAIL + 1))
  FAILED_NAMES+=("main_demo")
fi

echo
echo "$PASS passed, $FAIL failed."

if [ "$FAIL" -eq 0 ]; then
  rm -rf "$BUILD_DIR"
  exit 0
else
  echo "Failed: ${FAILED_NAMES[*]}"
  echo "Logs kept for inspection in: $BUILD_DIR"
  exit 1
fi
