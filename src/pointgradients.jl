# ------------------------------------------------------------------
# Copyright (c) 2018, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    pointgradients(img, points; [method])

Compute the gradients along all dimensions of N-dimensional `img`
at `points` using `method`. Default method is `:ando3`.
"""
function pointgradients(img::AbstractArray, points::AbstractVector; method=:ando3)
  extent = size(img)
  ndirs = length(extent)
  npoints = length(points)

  # smoothing weights
  weights = (method == :sobel ? [1,2,1] :
             method == :ando3 ? [.112737,.274526,.112737] :
             error("Unknown gradient method: $method"))

  # pad input image
  padimg = padarray(img, Pad(:replicate, ones(Int, ndirs), ones(Int, ndirs)))

  # gradient matrix
  G = zeros(npoints, ndirs)

  # compute gradient for all directions at specified points
  for i in 1:ndirs
    # kernel = centered difference + perpendicular smoothing
    if extent[i] > 1
      # centered difference
      idx = ones(Int, ndirs); idx[i] = 3
      kern = reshape([-1,0,1], idx...)
      # perpendicular smoothing
      for j in setdiff(1:ndirs, i)
        if extent[j] > 1
          idx = ones(Int, ndirs); idx[j] = 3
          kern = broadcast(*, kern, reshape(weights, idx...))
        end
      end

      A = zeros(size(kern))
      shape = size(kern)
      for (k, icenter) in enumerate(points)
        i1 = CartesianIndex(ntuple(i->1, ndirs))
        for ii in CartesianIndices(shape)
          A[ii] = padimg[ii + icenter - i1]
        end

        G[k,i] = sum(kern .* A)
      end
    end
  end

  G
end
