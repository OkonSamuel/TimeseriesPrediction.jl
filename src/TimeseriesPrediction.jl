__precompile__()

"""
Prediction of timeseries using methods of nonlinear dynamics and timeseries analysis
"""
module TimeseriesPrediction

using Reexport
@reexport using DynamicalSystemsBase

include("localmodeling.jl")
include("streconstruction.jl")
include("prediction_alg.jl")


end
