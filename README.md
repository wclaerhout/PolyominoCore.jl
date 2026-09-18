# Polyomino.jl

A Julia implementation of polyominoes (sets of unit cells on a grid), compared up to
translation only (no rotation/reflection). Extracted from
[`polyomino_crn`](https://github.com/wclaerhout/polyomino_crn), which builds a
hypergraph chemical reaction network and quality-diversity search on top of this core.

## Core Concepts

- **`Polyomino`**: a connected set of grid cells, normalized to a canonical translation.
- **Parsing**: build a `Polyomino` from an ASCII drawing via `parse_polyomino` / `poly"..."`.
- **Concatenation**: attach one polyomino to another along a side (`concatenate`),
  with helpers to check validity and enumerate valid attachments.
- **Splitting**: enumerate ways to split a polyomino into connected pieces (`all_splits`,
  `unique_splits`).
- **Visualization**: plot a single polyomino or a pathway of polyominoes (`CairoMakie`).

## Status

Work in progress.
