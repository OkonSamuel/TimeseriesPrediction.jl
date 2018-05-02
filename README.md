![DynamicalSystems.jl logo: The Double Pendulum](https://i.imgur.com/nFQFdB0.gif)

Repository for predicting timeseries using methods from nonlinear dynamics and
timeseries analysis. It
is part of the library [DynamicalSystems.jl](https://juliadynamics.github.io/DynamicalSystems.jl/latest/).

| **Documentation**   |  **Travis**     | **AppVeyor** | Gitter |
|:--------:|:-------------------:|:-----:|:-----:|
|[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://JuliaDynamics.github.io/DynamicalSystems.jl/latest) | [![Build Status](https://travis-ci.org/JuliaDynamics/TimeseriesPrediction.jl.svg?branch=master)](https://travis-ci.org/JuliaDynamics/TimeseriesPrediction.jl) | [![Build status](https://ci.appveyor.com/api/projects/status/amgkws9l1cng2aov?svg=true)](https://ci.appveyor.com/project/JuliaDynamics/timeseriesprediction-jl) | [![Gitter](https://img.shields.io/gitter/room/nwjs/nw.js.svg)](https://gitter.im/JuliaDynamics/Lobby)

All exported names have detailed documentation strings!

## Timeseries Example
```julia
using TimeseriesPrediction

ds = Systems.roessler(ones(3))
dt = 0.1
data = trajectory(ds, 1000; dt=dt)
N_train = 6001
s_train = data[1:N_train, 1]
s_test  = data[N_train:end,1]

method = AverageLocalModel(2)
ntype = FixedMassNeighborhood(2)

p = 500
s_pred = localmodel_tsp(s_train, 3, 15, p; method=method, ntype=ntype)

s_pred_10 = localmodel_tsp(s_train, 3, 15, p÷10;
    method=method, ntype=ntype, stepsize = 10)

using PyPlot
figure()
plot(550:dt:600, s_train[5501:end], label = "training (trunc.)", color = "C1")
plot(600:dt:(600+p*dt), s_test[1:p+1], color = "C3", label = "actual signal")
plot(600:dt:(600+p*dt), s_pred, color = "C0", ls="--", label="predicted")
plot(600:dt*10:(600+p*dt), s_pred_10, color = "C2",
    lw=0, marker="s", label="pred. step=10")
title("AverageLocalModel, Training points: $(N_train), attempted prediction: $(p)",
size = 18)
xlabel("\$t\$"); ylabel("\$x\$")
legend(loc="upper left")
tight_layout()
```
![Average local model prediction](https://i.imgur.com/VJSjHMI.png)

## Spatio-Temporal Timeseries Example
We will predict the future of the Barkley model:
$$
\begin{align}
\frac{\partial u }{\partial t} =& \frac{1}{\epsilon} u (1-u)\left(u-\frac{v+b}{a}\right) + \nabla^2 u\nonumber \\
\frac{\partial v }{\partial t} =& u - v
\end{align}
$$
Here $u, v$ are *fields* of two spatial dimensions.

Running the file `examples/barkley_tspred.jl` takes a couple of minutes, but
produces:

![Barkley prediction](https://i.imgur.com/vQ2FbRH.gifv)

The example first simulates the Barkley model.
Then, after a simulation of `1000` time steps,
it makes a temporal prediction of one of the two fields ($v$) for `200` time steps.
The animated figure shows the true evolution of the model, the prediction
and the error of the prediction.
