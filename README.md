# Resume -- Uday Kiran Padhy

Two ATS-friendly, single-page LaTeX resumes from a shared source tree:

| Variant | Target audience | Output |
| --- | --- | --- |
| Backend / Platform | SWE roles emphasizing APIs, distributed systems, infrastructure, security | `resume-backend.pdf` |
| AI / ML Engineer | Roles emphasizing LLM agents, RAG, fine-tuning, RL, AI product delivery | `resume-aiml.pdf` |

Shared content (header, education, preamble, formatting commands) lives at the root and under `src/`. Variant-specific content is split into `src/{summary,experience,projects,skills,achievements}-{backend,aiml}.tex`.

## Design choices

- **Font:** Open Sans (Google's open-source font), loaded via the `opensans` LaTeX package at `scale=0.92` so the contact line fits on one row. Italic and bold are real Open Sans variants, not synthesized.
- **Icons:** FontAwesome 5 icons in the contact header (`\faPhone`, `\faEnvelope`, `\faGlobe`, `\faLinkedin`, `\faGithub`). The icons are decorative; the URLs and text alongside them are what ATS extracts.
- **Clickable contact:** Phone number is wrapped in `\href{tel:+91...}{...}`, email in `\href{mailto:...}{...}`, every social link in a regular `\href{https://...}{...}`. Visible text for LinkedIn / GitHub is shortened to the username so the full chip fits one line; the underlying URL still points at the full address.
- **Linear layout:** Company, role, and date lines use inline em-dash separators (no nested `tabular*`, no `\hfill`). PDF text extractors return them in human reading order with proper spaces.
- **Ligature-free extraction:** `microtype` with `\DisableLigatures{encoding = *, family = *}` plus `\input{glyphtounicode}` + `\pdfgentounicode=1` means `pdftotext` / `pypdf` see `efficiency` and `flagged`, not the `eﬃciency` / `ﬂagged` ligature glyphs.
- **Single page:** Margins are pushed (`\topmargin -0.75in`, `\textheight +1.5in`) and content tuned per variant so each PDF fits exactly one US Letter page without shrinking the body font.
- **Section order:** `Summary` -> `Experience` -> `Projects` -> `Skills` -> `Education` -> `Achievements`.
- **Gainsight role progression:** One company entry with an italic "Promoted twice: ASE -> SE -> Senior SE" note, then three independent role lines (Senior SWE, SWE, ASE) each with their own bullets.
- **Skills tightened:** Only keywords that are backed by an experience bullet or a project. No filler entries (`DDD`, `Data Structures & Algorithms`, unsupported tools).
- **Projects:** Two featured projects per variant, each title hyperlinked to its portfolio detail page (`https://udaykp.dev/#detail-proj-...`). Backend variant emphasizes the systems/platform/evaluation angle; AI/ML variant emphasizes model/data/training/serving outcomes.

## File layout

```
ResumeBuilderLatex/
|-- resume-backend.tex          # backend variant entry point
|-- resume-aiml.tex             # AI/ML variant entry point
|-- preamble.tex                # shared font / encoding / margin setup
|-- custom-commands.tex         # \companyEntry, \roleLine, \projectHeading, bullet wrappers
|-- src/
|   |-- heading.tex                  # shared: name + single-line contact chip
|   |-- education.tex                # shared
|   |-- summary-backend.tex          | summary-aiml.tex
|   |-- experience-backend.tex       | experience-aiml.tex
|   |-- projects-backend.tex         | projects-aiml.tex
|   |-- skills-backend.tex           | skills-aiml.tex
|   |-- achievements-backend.tex     | achievements-aiml.tex
|-- Makefile                    # build orchestration
|-- Dockerfile                  # containerized build
|-- .github/workflows/build.yml # CI matrix build for both variants
|-- .claude/launch.json         # preview server config (Python http.server on :8123)
|-- index.html                  # local preview UI (gitignored)
|-- resume-{backend,aiml}.png   # preview snapshots (gitignored)
|-- .gitignore
|-- README.md
```

## Build locally

Requires a TeX distribution with `latexmk` plus the `opensans`, `fontawesome5`, and `microtype` packages. TinyTeX and TeX Live full both ship these.

```bash
make            # build resume-backend.pdf + resume-aiml.pdf
make backend    # backend only
make aiml       # AI/ML only
make watch      # auto-rebuild backend variant on save (latexmk -pvc)
make clean      # purge aux files
```

### Install TeX Live

| Platform | Command |
| --- | --- |
| macOS (MacTeX) | `brew install --cask mactex-no-gui` |
| macOS (TinyTeX) | `curl -sL https://yihui.org/tinytex/install-bin-unix.sh \| sh` then `tlmgr install opensans fontawesome5 microtype preprint fontaxes mweights enumitem titlesec hyperref fancyhdr babel-english xcolor` |
| Ubuntu / Debian | `sudo apt-get install texlive-full latexmk` |
| Fedora | `sudo dnf install texlive-scheme-full latexmk` |

If you used the TinyTeX path above and a future build complains about a missing `.sty`, install just that package via `tlmgr install <name>`.

## Build with Docker

No local LaTeX install needed.

```bash
docker build -t resume-builder .
docker run --rm -v "$(pwd):/resume" resume-builder
```

Both `resume-backend.pdf` and `resume-aiml.pdf` land in the project root.

## Build in CI

`.github/workflows/build.yml` runs on every push and pull request as a matrix over both variants (`xu-cheng/latex-action@v3` with `pdflatex` under `latexmk`). Each variant uploads its own artifact (`resume-backend-pdf`, `resume-aiml-pdf`) with 90-day retention. Download from the workflow run page.

## Preview workflow (no Chrome)

Two-variant changes are easiest to compare side-by-side via the bundled preview tooling:

1. `make` to rebuild PDFs.
2. Run `sips -s format png -Z 1200 resume-backend.pdf --out resume-backend.png` (and the same for `aiml`) to refresh the snapshots (these are also called automatically when `index.html` is regenerated).
3. The preview server config at `.claude/launch.json` serves the project root on `http://127.0.0.1:8123` via `python3 -m http.server`. `index.html` lays the two PNG snapshots side-by-side.
4. Open the preview pane (or visit `http://127.0.0.1:8123` once the server is started by your editor / Claude Code).

`index.html` and the `.png` snapshots are gitignored so they never end up in commits.

## Customizing content

| File | Purpose |
| --- | --- |
| `src/heading.tex` | Name + contact chip. Drop the LeetCode profile URL here -- it lives in the variant-specific achievements files. |
| `src/summary-*.tex` | One-line role-specific summary. |
| `src/experience-*.tex` | Same three Gainsight role lines in both variants; bullets reordered and reframed by variant. |
| `src/projects-*.tex` | Same two featured projects, tech-stack labels and framing differ per variant. |
| `src/skills-*.tex` | Variant-specific keyword grouping. |
| `src/achievements-*.tex` | Variant-specific framing of LeetCode rank + Smart India Hackathon (AI/ML variant leans into the computer-vision/NLP angle of the hackathon project). |
| `src/education.tex` | Shared. |
| `preamble.tex` | Font choice, ligature handling, margin sizing. |
| `custom-commands.tex` | `\companyEntry{company}{location}{date}{note}`, `\roleLine{title}{date}`, `\projectHeading{title}{stack}`, bullet wrappers. |

## Verification checks

After any edit, before considering the change shipped, the PDFs must pass:

1. **Single page each** -- `pdfinfo` reports `Pages: 1` (or the build log shows `Output written on ... (1 page, ...)`).
2. **ATS text extraction** -- `pdftotext -layout` (or `pypdf.PdfReader.extract_text()`) returns:
   - all section headings,
   - all three Gainsight role titles with their dates,
   - core keywords (RAG, LangGraph, FastAPI, GRPO, SSO, Snyk, etc.),
   - no ligature artifacts (`eﬃciency`, `ﬂagged`, `ﬁnd`),
   - no collapsed strings such as `EngineerAug` or `EnvironmentPython`.
3. **Hyperlinks present** -- the PDF's `/Annots` array contains `tel:+91...`, `mailto:...`, the LinkedIn, GitHub, portfolio, two `#detail-proj-...` deep-links, and the LeetCode profile URL.
4. **Visual review** -- both variants readable at 100% zoom in the preview pane, no clipped content at the page bottom, no cramped spacing, restrained bolding.