# Deprecated in v0.1.2; to be removed in v0.2.
Base.@deprecate n_blocks(p::Polyomino) length(p)
Base.@deprecate poly_height(p::Polyomino) size(p, 1)
Base.@deprecate poly_width(p::Polyomino) size(p, 2)
