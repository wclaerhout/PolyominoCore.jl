function visualise_polyomino(Polyomino::Polyomino)
	height = maximum([r for (r, _) in Polyomino.coordinates])
	length = maximum([c for (_, c) in Polyomino.coordinates])
	
	f = Figure()
	ax = Axis(f[1, 1], limits = (0,length+1, 0,height+1), xgridvisible = false, 
		  aspect = DataAspect(),
          ygridvisible = false)
	
    hidedecorations!(ax)
    hidespines!(ax)
	for (r, c) in Polyomino.coordinates
		poly!(Rect(c, r, 1, 1), color = :slategray1,
			  strokewidth = 2,
		strokecolor = :black)
	end
	return f
end	