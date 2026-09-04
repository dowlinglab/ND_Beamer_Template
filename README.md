# Notre Dame Beamer Template

A Beamer template with a University of Notre Dame theme. For math typesetting, it is definitely better than using existing PowerPoint templates.

Forked and modernized by the Dowling Lab, September 2026. The short version: every visual element (title bar, section-name bar, title text, canvas, body text, corner logo, title-bar monogram, title-page mark) is now its own independent color/visibility choice instead of a fixed palette, real current official Notre Dame marks replace the old bundled/wrong-college logos, and a few new commands (`\ndcornerlogo`, `\ndlogonote`, `\hl`) were promoted from patterns built ad hoc in real decks. Full change history is in `beamerthemeNotreDame.sty`'s own header comment.

## Installation

Copy the `.sty` files and the `logos/` directory into the same directory as your `.tex` source (or put them somewhere your `TEXINPUTS` can find them).

```latex
\documentclass{beamer}
\usetheme{NotreDame}
\begin{document}
%% Title slide -- this exact wrapping is required, see note below
{
\setbeamertemplate{navigation symbols}{}
\setbeamertemplate{background}{\ndtitlepagelogodraw}
\begin{frame}[plain]
  \titlepage
\end{frame}
}
%% Other slides
\end{document}
```

**The title slide needs that exact wrapping — `\setbeamertemplate{background}{\ndtitlepagelogodraw}` set *outside* `\begin{frame}`, in its own group, right beside the navigation-symbols line.** FOUND BY TESTING 2026-09: Beamer locks in which background template a frame will use at `\begin{frame}` time, before the frame's own content (including `\titlepage` itself) has run — so setting the background from *inside* `\titlepage`'s own hook is simply too late, and doesn't take effect for that same frame (confirmed with a minimal isolated case). `\ndtitlepagelogodraw` is always defined, even when `titlepagelogo=none` (in which case it's empty), so this line is always safe to include verbatim regardless of your option choices.

See `main.tex` / `document.tex` for a fuller working example — build it with `pdflatex main.tex` (twice, for reasons explained below) to see several of the options in this README rendered.

## Options

Every option is `key=value`; combine them freely in one `\usetheme[...]{NotreDame}` call:

```latex
\usetheme[background=blue, titlebar=gold, cornerlogo=white, mark=secondary]{NotreDame}
```

### Structural (unchanged from upstream)

| Option | Effect |
|---|---|
| `nav` | Shows Beamer's navigation-symbol row, bottom-right (off by default) |
| `noslidenumbers` | Hides the page-number footer (shown by default) |
| `fullFooter` | Swaps the simple page-number footer for a 3-part title/author/date bar (can't combine with `noslidenumbers`) |

### The independent style options

Each of these is its own choice with its own sensible default — not a single overall "light/dark mode" the rest cascade from, though several defaults do still consult `background`, the one choice everything else most naturally reads against.

| Option | Values | Default |
|---|---|---|
| `background` | `white`, `blue` | `white` |
| `titlebar` | `blue`, `gold`, `none` | contrasts with `background` (blue bar on white, gold bar on blue) |
| `sectionbar` | `blue`, `gold`, `none` | `none` |
| `titlecolor` | `blue`, `gold`, `black`, `white` | derived from `titlebar` (white on blue bar, black on gold bar) or from `background` if `titlebar=none` |
| `textcolor` | `black`, `blue`, `gold`, `white` | derived from `background` (blue text on white, white text on blue) |
| `cornerlogo` | `blue`, `gold`, `black`, `white`, `fullcolor`, `none` | `none` |
| `monogram` | `blue`, `gold`, `gold-metallic`, `white`, `none` | contrasts with `titlebar` (white on blue bar, blue on gold bar); forced to `none` if `titlebar=none` |
| `titlepagelogo` | `blue`, `gold`, `black`, `white`, `fullcolor`, `none` | derived from `background` (blue on white, gold on blue) |
| `mark` | `primary`, `secondary` | `primary` |
| `highlight` | `gold`, `green`, `blue`, `none` | `gold` |

There is **no black-canvas option**. `background` is white or blue (NDBlue) only — that was a deliberate call, not an oversight.

**There is no bad-combination guard.** Every value is independently settable, including ones that read poorly (`background=blue, textcolor=blue` is legal and will look wrong). This theme trusts you to pick sensibly; it doesn't second-guess you.

### `titlebar`, `sectionbar`, `titlecolor`

- `titlebar=none` removes the colored title-bar box entirely — the frame title sits directly on the canvas, in whatever `titlecolor` resolves to, with no logo slot (the title-bar's own monogram doesn't make sense with no bar to sit in, so `monogram` is forced to `none` whenever `titlebar=none`, regardless of what you set it to).
- `sectionbar` shows the current `\section{}` name in its own colored bar above the title, when the option isn't `none`. It only ever shows text when the document actually has `\section` commands.
- `titlecolor` is the frametitle's own text color, separate from `textcolor` (the body).

### `mark`, `cornerlogo`, `monogram`, `titlepagelogo` — which logo goes where

There are three logo placements, each independently colorable, and one shape choice (`mark`) that applies to only one of them:

1. **Title page** (`titlepagelogo`) — always the **primary** (wide) academic mark, regardless of `mark`. Per Notre Dame's own guidelines: the secondary mark and the monogram are for when space doesn't allow the primary mark, and a title page always has the room.
2. **Corner logo** (`cornerlogo`, drawn via `\ndcornerlogo`) — the one placement where space really can be tight, so `mark=primary|secondary` applies here: `primary` is the wide lockup (shield beside "University of Notre Dame"), `secondary` is the compact vertical lockup (shield above "Notre Dame"), for tighter corners.
3. **Title-bar monogram** (`monogram`) — the small "ND" letterform inside the frametitle bar (only relevant when `titlebar != none`). This is the tightest placement of the three, which is why it's the one spot using the monogram asset instead of the full academic mark.

`cornerlogo` and `titlepagelogo` support `fullcolor` (the real two-tone gold-shield/blue-wordmark treatment); `monogram` doesn't have a fullcolor variant (the mark is a solid letterform, not a two-part lockup) but does have `gold-metallic` as a second gold option.

The title-page mark sits in the bottom-left corner, larger than the corner logo elsewhere (not centered under the author/date block, which is beamer's own default `\titlegraphic` placement). `\ndtitlepagelogomargin` (default `0.15mm`) and `\ndtitlepagelogoheight` (default `2.6cm`) control its distance from the page corner and its size — override with `\renewcommand{...}{...}` before `\begin{document}`, same as the corner logo's own analogous lengths below. Drawn via `\ndtitlepagelogodraw` — see the Installation section above for the exact wrapping this needs around your title-slide frame, and why.

## `\hl[color]{text}` — bold, colored emphasis

```latex
\hl{a phrase}            % bold, deck-wide default color (the `highlight` option)
\hl[gold]{a phrase}      % bold, gold, regardless of the deck default
\hl[blue]{a phrase}      % bold, NDBlue
\hl[green]{a phrase}     % bold, Irish Green
\hl[none]{a phrase}      % bold only, no color, regardless of the deck default
```

Matches a real habit: bold a few words in a sentence for emphasis, not the whole sentence.

## `\ndcornerlogo` and `\ndlogonote[align]{text}`

Only defined when `cornerlogo` is not `none` (they position themselves relative to that logo's actual measured size, so there's nothing to measure against otherwise).

- `\ndcornerlogo` draws the corner logo. Set automatically as the frame background whenever `cornerlogo != none`; call it yourself (e.g. `\setbeamertemplate{background}{\ndcornerlogo}`) if a specific deck wants more control.
- `\ndlogonote[align]{text}` places a note in the white space beside the corner logo: horizontally centered between the logo's right edge and the slide's right edge, vertically centered on the logo's own vertical middle. `[align]` defaults to `center` (a short takeaway line); pass `[left]` for a left-aligned reference list.
- `\ndcornerlogomargin` (default `0.15mm`) and `\ndcornerlogoheight` (default `0.975cm`) control the logo's distance from the page corner and its size — override with `\renewcommand{...}{...}` before `\begin{document}`.

**Known limitation, not automatically resolved:** `\ndcornerlogo`/`\ndlogonote` assume nothing else occupies the bottom strip of the slide. Both `nav` (the navigation-symbol row) and `fullFooter` (the 3-part footer bar) visibly collide with them — none of these three features know about each other. Don't combine `cornerlogo` with `nav` or `fullFooter` without checking the render.

**Compilation note:** both use TikZ's `remember picture, overlay` to reference the page edges, which is standard TikZ behavior needing a second compilation pass to position correctly (the first pass doesn't yet know the page's absolute layout) — a single `pdflatex` run will show them misplaced at (0,0); `latexmk` (or any build that reruns until stable) handles this automatically.

## The demo (`main.tex` / `document.tex`)

`document.tex` is a short, working demo of this theme's own options and commands (colors/background, `\hl`, the corner logo and note box, the three logo placements) — not a generic "how Beamer works" tutorial. An earlier, much longer `document.tex` (inherited from upstream, largely unrelated to this theme specifically) relied on the classic `pstricks` package for some of its diagrams; `pstricks` needs the classic `latex`+`dvips`+`ps2pdf` pipeline to actually draw anything and fails outright under plain `pdflatex`, which this fork and everything built from it uses — so it's gone, along with the `pstricks` dependency itself.

**Compiled demo output (`.pdf`, `.ps`, and other build artifacts) is intentionally not committed to this repository** — `.gitignore` excludes it. Build the demo yourself:

```sh
pdflatex main.tex
pdflatex main.tex   # twice, for \ndlogonote's overlay coordinates -- see above
```

## Other suggested packages

* `tikz` — already loaded by this theme (used for the corner logo/note box)
* `listings` — for source code listings
* `fontspec` — if using XeLaTeX

## Credits

Author: Daniel Howard (dhoward3@nd.edu)
Modified Release: February 2017

Adapted from author below:
Author: Tristan Ravitch (travitch@cs.wisc.edu)
Initial Release: June 2009
Public Domain

Forked and modernized by the Dowling Lab, September 2026.

## Appendix: the `\Highlight` snippet

Unrelated to `\hl` above — a pre-existing convenience for source-code listings, carried over from the retired `beamercolorthemeNotreDame*.sty` files (`HighlightBackground` is still defined, directly in `beamerthemeNotreDame.sty` now):

```latex
\newcommand*{\alphabet}{ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz}
\newlength{\highlightheight}
\newlength{\highlightdepth}
\newlength{\highlightmargin}
\setlength{\highlightmargin}{2pt}
\settoheight{\highlightheight}{\alphabet}
\settodepth{\highlightdepth}{\alphabet}
\addtolength{\highlightheight}{\highlightmargin}
\addtolength{\highlightdepth}{\highlightmargin}
\addtolength{\highlightheight}{\highlightdepth}
\newcommand*{\Highlight}{\rlap{\textcolor{HighlightBackground}{\rule[-\highlightdepth]{\linewidth}{\highlightheight}}}}
```

This lets you highlight a line in a code listing:

```latex
\lstinputlisting[language=C,moredelim={**[il][\Highlight]{@}}]{file.c}
```

The `moredelim` option, with the declarations above, highlights any line in `file.c` prefixed with `@`.
