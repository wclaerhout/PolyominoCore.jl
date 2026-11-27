# Plan: from extracted core to a lean, general-purpose package

Status: draft, 2026-11-17. Applies to `Polyominoes.jl` v0.1.1. The package was renamed
`PolyominoCore.jl` on 2026-11-26 and `PolyominoTools.jl` on 2026-11-27 (see R6); older entries below keep the old name.

## How to work in this repo

Work through the **Kaimon MCP environment** and prefer its tools over shell equivalents:

- **Run Julia in the live REPL** with `ex`, not `julia -e` or `julia --project` in Bash.
  The REPL is shared with the user, so both see the same state; Revise reloads `src/`
  edits before every eval. Return a final expression instead of using `println`/`@show`.
  If no session is connected for this project, start one with `start_session`.
- **Tests**: `run_tests` (collect background runs with `check_tests`), not
  `Pkg.test()` from the shell.
- **Finding code**: `search_code` when you can only describe what you're looking for,
  `grep_code` when you have an exact token; `goto_definition`, `search_methods`,
  `type_info` and `list_names` for introspection.
- **Changing code**: `rename_symbol` for renaming Julia identifiers; `edit_code` for
  mechanical multi-file changes; `format_code` for formatting.
- **Packages**: `pkg_add` / `pkg_rm` instead of editing `Project.toml` by hand.
- Long evals become background jobs: do other work and collect them with `check_eval`;
  never `sleep` to wait.

## Goal

Make Polyominoes.jl a small, registrable package that anyone working with polyominoes
in Julia would reach for, without making it bigger than it needs to be. Target for
**v0.2.0**: zero hard dependencies, about 20 public names, enumeration verified against
OEIS, plotting as an optional extension, CI and docs in place. Everything specific to
the research (reaction networks, assembly) stays in `polyomino_crn`.

Guiding rules:

1. **General before clever.** Every feature must make sense to someone who has never
   heard of chemical reaction networks.
2. **Small surface.** Prefer one well-named function with a `symmetry` keyword over
   three variants.
3. **Oracles over examples.** Wherever a known answer exists (OEIS counts, algebraic
   invariants), the tests check against it.
4. **Don't strand the downstream.** `polyomino_crn` must keep working: it pins v0.1
   until it has been migrated.

## Where it stands (v0.1.1)

Already general and worth keeping:

- `Polyomino`: normalized for translation, `==`/`hash` consistent, constructor checks
  4-connectivity
- `parse_polyomino` / `poly"..."`
- opt-in symmetry: `rotate90`, `reflect`, `orientations`, `canonical`, `is_equivalent`
  with `:translation | :rotation | :full`
- `all_splits` / `unique_splits` (two connected pieces, with multiplicities)

Problems found in review:

| # | Problem | Where |
|---|---|---|
| 1 | `Test` is in `[deps]`; there is no `julia` compat entry | `Project.toml` |
| 2 | CairoMakie is a hard dependency, so every `using Polyominoes` loads Makie | `Project.toml`, `src/visualisation.jl` |
| 3 | `visualize_pathway` uses `yreversed = true`, so shapes are drawn upside down compared with `visualize_polyomino` and the parser | `src/visualisation.jl` |
| 4 | `Cell` and `Shift` are exported but never used; commented-out code refers to the nonexistent `MONOMINO` | `src/types.jl`, `src/visualisation.jl` |
| 5 | Docstrings refer to `docs/research_framing.md`, "§2" and "scope A/B" (not in this repo) and use reaction terms | `src/concat_logic.jl` |
| 6 | `concatenation_possible` uses `try/catch` (hides real bugs); its default `side` is the string `"bottom"` | `src/concat_logic.jl` |
| 7 | `coordinates(p)` sorts and allocates on every call and is used inside `poly_height`, `poly_width` and `boundary_cells`; `boundary_cells` checks `∉` on a `Vector`, which scans the whole list each time | `src/types.jl`, `src/concatenation.jl` |
| 8 | The joining API (`side`/`pos1`/`pos2`, four BitMatrices with duplicate products) reflects the CRN model, not a general need | `src/concatenation.jl`, `src/concat_logic.jl` |
| 9 | No `show` method: a polyomino prints as a raw `Set` | `src/types.jl` |
| 10 | Tabs and spaces are mixed; no CI, docs or Aqua checks; tests are thin (`type_test.jl` and `concatenation_test.jl` have three assertions each) | repo |

## Target scope

### In

| Area | Public names (proposal) |
|---|---|
| Type and construction | `Polyomino`, `parse_polyomino`, `@poly_str`, `coordinates`, `Base.show` (ASCII drawing), `Base.length` (cell count), `Base.size` (height, width), `Base.in` (cell membership), iteration over cells |
| Symmetry | `rotate90`, `reflect`, `orientations`, `canonical`, `is_equivalent` (public, not exported), `symmetry_group` |
| Enumeration | `polyominoes(n; symmetry = :translation)` |
| Structure | `is_connected`, `perimeter`, `nholes` |
| Splitting | `all_splits`, `unique_splits(p; symmetry)` |
| Joining | `attachments(a, b; symmetry = :translation)`, `attach(a, b, offset)` |
| Plotting (extension) | `visualize_polyomino`, `visualize_polyominoes` (replaces `visualize_pathway`) |

### Out (non-goals)

Reaction networks, assembly index, search; tiling and exact cover; chess problems
(already in `Polyomino.jl`); random generation; other lattices. Revisit only if there is
a concrete user outside this PhD.

## Phases

### Phase 0: Hygiene (no API change, ship as v0.1.2)

- [x] `Project.toml`: move `Test` to `[extras]` + `[targets]`; add `julia = "1.10"` (the
      LTS); add compat for every dependency
- [x] Turn plotting into a package extension: `Makie` (or `CairoMakie`) under
      `[weakdeps]`, `[extensions] PolyominoesMakieExt = "Makie"`, code in
      `ext/PolyominoesMakieExt.jl`. Declare the function names (with no methods) in the
      main module so `visualize_polyomino` is exported either way. Set the Makie compat
      bound to whatever `Pkg` resolves alongside CairoMakie 0.15.
- [x] Fix the upside-down `visualize_pathway` (#3) and add a test that checks the y-axis
      direction or limits on the returned figure
- [x] Remove `Cell` and `Shift` and the dead commented-out block (#4). This is technically
      breaking; check that `polyomino_crn` doesn't use them, otherwise defer to v0.2.
      **Status:** dead block removed in Phase 0; `Cell`/`Shift` moved into
      `polyomino_crn` and removed here together with the other deprecated names.
- [x] Remove CRN references from docstrings (#5)
- [x] Normalize to 4-space indentation in one formatting-only commit
- [x] Add CI: GitHub Actions running `Pkg.test()` on Julia 1.10 and the latest release,
      Linux only to start
- [x] Add `Aqua.jl` tests (ambiguities, unbound type parameters, stale dependencies,
      compat bounds) as a test-only dependency

**Done when** CI is green, `using Polyominoes` loads without Makie, and the README shows
a three-line example.

### Phase 1: Representation and basics

- [x] Decide the internal representation (research question R1), then implement it.
      Current leading option: store the **sorted `Vector{Tuple{Int,Int}}`** computed once
      in the constructor, plus a cached hash. Then `coordinates` returns it with no work,
      `==` is a vector comparison, and membership checks use `searchsortedfirst`.
- [x] `Base.show(io, ::MIME"text/plain", p)` prints the ASCII drawing in the same
      `#`/`.` format that `poly"..."` reads, so a printed shape can be pasted back in.
      Add a one-line compact `show` for use inside collections.
- [x] `Base.length`, `Base.size`, `Base.in`, `Base.iterate`; deprecate `n_blocks`,
      `poly_height` and `poly_width` with `Base.@deprecate`
- [x] Switch new code to `ArgumentError`; replace `concatenation_possible`'s
      `try/catch` with a direct overlap check (#6)

**Done when** a benchmark of `canonical` and `all_splits` on all fixed 8-ominoes is no
slower than v0.1 (ideally clearly faster) and all old tests pass.

### Phase 2: Enumeration

- [x] `polyominoes(n; symmetry)`: grow level by level. For each (n−1)-omino, add every
      empty 4-neighbour cell, canonicalize under `symmetry`, and deduplicate in a `Set`.
      This is simple, obviously correct, and fast enough up to about n = 12 (505,861
      fixed shapes).
- [x] Tests against OEIS for n = 1…10 (table below). A throwaway Python prototype of
      exactly this algorithm reproduced all three columns up to n = 10.
- [ ] Optional later: a Redelmeier-style counter (`count_polyominoes`) for larger n
      without storing the shapes. Only add it if someone needs it (R2).

| n | fixed (A001168) | one-sided (A000988) | free (A000105) |
|---|---|---|---|
| 1 | 1 | 1 | 1 |
| 2 | 2 | 1 | 1 |
| 3 | 6 | 2 | 2 |
| 4 | 19 | 7 | 5 |
| 5 | 63 | 18 | 12 |
| 6 | 216 | 60 | 35 |
| 7 | 760 | 196 | 108 |
| 8 | 2725 | 704 | 369 |
| 9 | 9910 | 2500 | 1285 |
| 10 | 36446 | 9189 | 4655 |

### Phase 3: Joining and splitting, generalized

- [x] `attach(a, b, offset)`: the union of `a` and `b` shifted by `offset`; throws if the
      two overlap or don't touch along an edge
- [x] `attachments(a, b; symmetry)`: every **distinct** polyomino formed by placing `b`
      (in any orientation allowed by `symmetry`) edge-adjacent to `a` without overlap.
      Returns `Vector{Polyomino}`, with an option to also return the offsets. This
      replaces the four-BitMatrix output of `all_valid_concatenations`.
- [x] Remove reaction terms from `unique_splits`' docstring; keep the multiplicity count,
      since it's a general quantity
- [x] Move `concatenate(...; side, pos1, pos2)`, `boundary_cells`,
      `concatenation_possible` and `all_valid_concatenations` out of the package (R4).
      Either `polyomino_crn` reimplements them on top of `attach` in about 30 lines,
      or they stay one release with deprecation warnings.
      **Status (2026-11-17):** `polyomino_crn` reimplements them in
      `src/side_concatenation.jl` on top of `attach` (verified identical over 961
      shape pairs); removed here, along with `n_blocks`, `poly_height`, `poly_width`,
      `Cell` and `Shift`. Version is now `0.2.0-DEV`.
- [x] Property tests: every result of `attachments(a, b)` has `length(a) + length(b)`
      cells and can be split back into `(a, b)` by `all_splits`; there are no duplicates
      under `canonical`

### Phase 4: Small set of properties

- [x] `perimeter(p) = 4·length(p) − 2·(number of edge-adjacent cell pairs)`
- [x] `nholes(p)`: the number of 4-connected components of empty cells inside the
      bounding box (padded by 1) that don't touch the border. Empty cells connect only
      through edges: two filled cells touching at a corner separate the empty cells
      around them.
- [x] `symmetry_group(p)`: the subgroup of the 8 square symmetries (D4) that leaves `p`
      unchanged; its size is 8 / (number of distinct orientations). Useful for orbit
      counts and as a test oracle.

Stop here. Anything else needs a concrete user first.

### Phase 5: Docs and registration (v0.2.0)

- [x] Documenter.jl site with a tutorial (parse → print → canonicalize → enumerate →
      split/attach → plot) and an API page, deployed from CI to `gh-pages` (GitHub
      Pages serves `gh-pages`)
- [x] README: what it is, a 10-line example, how it differs from `Polyomino.jl`
- [x] Release polish (#12, #13): `visualize_pathway` renamed to
      `visualize_polyominoes` (with `ncols`); TagBot and CompatHelper workflows;
      `DOCUMENTER_KEY` deploy key and secret, so TagBot's tags build versioned docs;
      JET as a test dependency (runs on Julia ≥ 1.12); version set to `0.2.0`
- [ ] `polyomino_crn` migrated and depending on v0.2
      **Status:** migrated (polyomino_crn#20, #21 owns its `visualize_pathway`); it
      still uses a path dependency, so pin `PolyominoTools = "0.2"` once v0.2.0 is
      registered.
- [x] Pre-registration API review (2026-11-18). Done 2026-11-25. One-page overview of the public API:
      https://claude.ai/artifact/5P8DoqGdYAAX3e222pPaoJ
      Fix before registering (changing these after 0.2 is breaking or confusing):
  - [x] Mixed exception types: the `Polyomino` constructor (empty or disconnected
        cells), `parse_polyomino` (bad character) and every `symmetry` validation
        throw `ErrorException` via `error(...)`, while `attach`, `polyominoes(0)` and
        the plotting functions throw `ArgumentError`. Switch all to `ArgumentError`
        (Phase 1 asked for this) and test the exception types.
  - [x] `unique_splits` docstring signature reads `unique_splits(p)`; make it
        `unique_splits(p; symmetry = :translation)` so the keyword shows on the API page.

      Decide:
  - [x] `is_connected(p::Polyomino)` always returns `true` (the constructor enforces
        connectivity). Keep it for symmetry with the cell-collection method, or drop it.
        **Decision:** keep; the docstring explains why it is always `true`.
  - [x] Coordinate convention (R5): keep `(r, c)` with rows growing upward or switch
        to `(x, y)`. Affects `coordinates`, `in`, `attach` offsets, `size`.
        **Decision:** keep `(r, c)` (see R5).
  - [x] `(r, c) in p` checks normalized coordinates (the shape shifted to `(1, 1)`),
        not the cells as passed to the constructor. Document this in a docstring on
        the `in` method. **Done:** docstring with a doctest.
- [x] Rename the GitHub repository to `PolyominoTools.jl` (Settings → Rename) and update
      the local `origin` URL; GitHub redirects the old URLs. **Done 2026-11-27.**
- [ ] Register with `@JuliaRegistrator register`. The rename to `PolyominoTools` should
      clear the name-similarity check that "Polyominoes" failed against `Polyomino`.
      If AutoMerge still flags it, comment on the registry PR explaining the difference
      (a general geometry, symmetry and enumeration core versus chess problems and
      random generation).
- [ ] Optional later: a short announcement after registration. Either a Discourse
      "Package Announcements" post (5–10 lines: what it does, one example, how it
      differs from `Polyomino.jl`, links) or one message in Slack/Zulip
      `#new-packages`. No rush; posting once `polyomino_crn` or a paper uses it gives
      a "used in" line.

## Open research questions and decisions

**R1. Internal representation.** Benchmark three candidates on (a) enumerating all fixed
10-ominoes, (b) `unique_splits` over all 8-ominoes, and (c) using shapes as `Dict` keys:

1. `Set{Tuple{Int,Int}}` (current)
2. sorted `Vector{Tuple{Int,Int}}` plus a cached `UInt` hash (proposed)
3. a bit-packed bounding-box mask (e.g. `UInt128` for shapes whose box fits in 128 cells)

Option 3 is the fastest but caps the size and complicates the code. Pick 2 unless it
loses by a wide margin. Keep the benchmarks in `benchmark/` with their own
`Project.toml` (BenchmarkTools), not as a dependency of the package.

**Decision (2026-11-17): option 2**, implemented in Phase 1. `benchmark/benchmarks.jl`,
Julia 1.13, v0.1 (option 1) → option 2: enumerate fixed 10-ominoes 682 → 633 ms;
`canonical(:full)` on all 8-ominoes 20.1 → 2.5 ms; `all_splits` 454 → 4.4 ms;
`unique_splits` 478 → 5.4 ms; 10,900 `Dict` insertions 1.54 → 0.20 ms. (`all_splits`
also switched to bitmask connectivity checks.) Option 3 was not benchmarked.

**R2. Enumeration algorithm.** Level-by-level growth with deduplication is enough for
listing shapes (memory grows with the count, fine up to about 12). Redelmeier's
algorithm (1981) counts fixed polyominoes without storing them and is the standard for
larger n. Decide whether counting beyond n = 12 is in scope; default answer: no.

**R3. `all_splits` scaling.** The current algorithm tries 2^(n−1) subsets, which is fine
up to about n = 16. An alternative: grow connected subsets containing the anchor cell
and keep those whose complement is connected, which skips most disconnected subsets.
Only do this if downstream work hits the limit.

**R4. What happens to `side`/`pos` concatenation.** It encodes a modelling choice from
the CRN (attach along a face, indexed by boundary position, outermost cell per row or
column). Recommendation: the general package offers only `attach` and `attachments`.
Any rule such as "no insertion into an enclosed cavity" is a filter that
`polyomino_crn` applies to their output.

**R5. Coordinate convention.** Keep `(r, c)` with rows growing upward (no churn
downstream), or switch to `(x, y)`, which is more conventional in combinatorics
software? Recommendation: keep `(r, c)` and document it prominently; changing it brings
no real gain.

**R6. Name.** Keep "Polyominoes" and request the override, or choose a name that passes
the automatic check. **Decision (2026-11-26):** rename to `PolyominoCore`, after forum
discussion; changed to `PolyominoTools` on 2026-11-27 (new logo). Module, extension (`PolyominoToolsMakieExt`), docs and URLs renamed; the UUID is
unchanged (the package was never registered).

## Downstream migration (`polyomino_crn`)

Before each breaking release:

1. Search for uses of every removed or renamed name: `Cell`, `Shift`, `n_blocks`,
   `poly_height`, `poly_width`, `concatenate`, `boundary_cells`,
   `concatenation_possible`, `all_valid_concatenations`, `visualize_pathway`.
2. Pin `PolyominoTools = "0.2"` (formerly `Polyominoes = "0.1"`) in `polyomino_crn` until
   it is migrated.
3. Port the `side`/`pos` helpers into `polyomino_crn` on top of `attach`, and check that
   its benchmark results (assembly indices, archive contents) are unchanged.
