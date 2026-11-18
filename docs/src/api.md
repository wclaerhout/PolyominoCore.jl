# API

```@meta
CurrentModule = Polyominoes
```

Exported names are listed without a prefix. The symmetry helpers are public but not
exported; use them as `Polyominoes.canonical` or bring them in with
`using Polyominoes: canonical`.

## Type and construction

```@docs
Polyomino
coordinates
parse_polyomino
@poly_str
is_connected
```

## Cells, size and membership

```@docs
Base.length(::Polyomino)
Base.size(::Polyomino)
Base.in(::Tuple{Integer,Integer}, ::Polyomino)
```

## Symmetry

```@docs
rotate90
reflect
orientations
canonical
is_equivalent
symmetry_group
```

## Enumeration

```@docs
polyominoes
```

## Properties

```@docs
perimeter
nholes
```

## Splitting

```@docs
all_splits
unique_splits
```

## Joining

```@docs
attach
attachments
```

## Plotting

These need a Makie backend, for example `using CairoMakie`.

```@docs
visualize_polyomino
visualize_polyominoes
```

## Index

```@index
```
