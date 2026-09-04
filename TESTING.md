# Testing

This repo has no CI. `test/run_regression.sh` is the regression suite: it
compiles a fixed matrix of small decks (`test/cases/*.tex`), each exercising
a real option combination, and reports which ones fail to compile.

## Running it

```sh
./test/run_regression.sh
```

Takes about 20-25 seconds. Requires `pdflatex` and `biber` on `PATH` (a
normal TeX Live install has both). Prints one `PASS`/`FAIL` line per case,
plus a final summary, and exits `0` if everything passed or `1` if anything
failed.

On success, its scratch build directory (under the system temp dir) is
deleted automatically. On failure, it's left in place and the script prints
its path — the `.log` files in there are the actual `pdflatex`/`biber`
output for whichever case(s) failed, and are the first thing to read.

## What it checks, and what it doesn't

Each case is a real, self-contained `.tex` file: a `\usetheme[...]` call
with a specific option combination, a title page, and usually one content
frame. The script compiles it twice (three times for the bundled demo, plus
a `biber` run) and treats it as a **failure only if the PDF wasn't produced,
or the log contains a genuine LaTeX error** (a line starting with `!` — the
error marker LaTeX itself uses, checked in preference to grepping for the
word "error", which also appears in several harmless package messages).

**By default this only catches things that make LaTeX itself error out** —
an undefined control sequence, a missing file, mismatched braces, that kind
of thing. It does **not** check that anything actually looks right: colors,
spacing, overlapping text, a logo landing in the wrong place, or a value
silently resolving to the wrong default. A change can pass every case here
and still be visibly broken.

A case can go further and assert a real numeric or logical outcome itself,
for bugs that compile perfectly cleanly and are just silently wrong
otherwise — `15_cornerlogo_size_override.tex` does this with a plain
`\ifdim` check against the actual measured logo width, `\typeout`-ing
`ND-TEST-FAIL: ...` if it doesn't match what the override should have
produced; the script treats that marker as a failure exactly like a `!`
error. Use this pattern for a new case whenever "did it compile" wouldn't
actually have caught the bug you're guarding against.

For anything touching layout, color
resolution, or logo placement, also render the affected case(s) to an image
and look at it:

```sh
pdflatex -interaction=nonstopmode test/cases/08_leftrule_default.tex
pdftoppm -png -r 150 08_leftrule_default.pdf out
```

(then view `out-1.png`, etc. — clean up the `.pdf`/`.aux`/etc. it leaves
behind afterward, or build in a scratch directory).

## What's covered

The cases in `test/cases/` are numbered by theme, not by strict priority:

| Case | What it exercises |
|---|---|
| `01_classic_default` | `titlelayout=classic` with no other options set |
| `02_classic_titlebar_none` | `titlebar=none` (the "simple look": no bar, no monogram slot) |
| `03_classic_blue_secondary_cornerlogo` | `background=blue` + `mark=secondary` + `cornerlogo` together |
| `04_classic_titlepagelogo_none_sectionbar` | `titlepagelogo=none` alongside `cornerlogo` and `sectionbar` |
| `05_classic_fullfooter` | the `fullFooter` structural option |
| `06_classic_nav_noslidenumbers` | `nav` + `noslidenumbers` together |
| `07_classic_full_options` | nearly every option set at once, including a low-contrast combination (`background=blue` + `titlepagelogo=fullcolor`) that's expected to look poor but must still compile — see "There is no bad-combination guard" in the README |
| `08_leftrule_default` | `titlelayout=leftrule` with no other options set |
| `09_leftrule_background_blue` | `leftrule` on a blue canvas (exercises `titlecolor`'s layout-aware default) |
| `10_leftrule_titlecolor_override_cornerlogo` | an explicit `titlecolor` override, plus `cornerlogo` (checks the title frame's background is correctly blanked rather than doubled) |
| `11_leftrule_titlepagelogo_none_no_venue` | `titlepagelogo=none` with no `\ndvenue` set (checks the date still prints on its own) |
| `12_leftrule_full_options` | `leftrule` combined with `cornerlogo`, `sectionbar`, and `mark=secondary` |
| `13_hl_all_colors` | `\hl{}` in every color, plus the deck-wide `highlight` default |
| `14_cornerlogo_logonote` | `\ndlogonote`, both `[center]` (default) and `[left]` |
| `15_cornerlogo_size_override` | `\renewcommand{\ndcornerlogoheight}` / `\ndcornerlogomargin` actually taking effect — asserted numerically via `\ifdim`, not just "compiled" (see below) |
| `16_leftrule_frametitle_contrast` | `titlelayout=leftrule` doesn't change what `titlecolor` (the per-slide frametitle bar's text color) defaults to — asserted via `\ifdefstring` against the internal `\nd@titlecolor`, not just "compiled" |
| `17_ndlogonote_anchor_override` | `\renewcommand{\ndlogonoteanchor}` actually taking effect — asserted via `\ifdefstring` against the resolved value |

The final `main_demo` line builds the actual bundled demo (`main.tex` +
`document.tex`, including a real `biber` run) as an end-to-end smoke test on
top of the isolated cases above.

## Adding a case

Drop a new self-contained `.tex` file into `test/cases/` — the script picks
it up automatically (it globs the directory; there's no registration list
to update). Follow the existing files as a template: a `\usetheme[...]`
call with the combination you want to check, a title page using the
wrapping pattern documented in the README (`\setbeamertemplate{background}`
set outside `\begin{frame}`), and usually one content frame. Add a row to
the table above describing what it covers.

Add a case whenever you fix a bug that could regress silently — the
`titlecolor` and `titlepagelogo`/`\ndvenue` cases above (09 and 11) exist
because both were real bugs found while building `titlelayout=leftrule`,
not because they were anticipated in advance.
