using PyPlot
using DynamicalSystemsBase
using StaticArrays


include("streconstruction.jl")
include("prediction_alg.jl")


function coupled_henon(M=100)
    function henon(du, u, p, t)
        du[1,1] = du[M,1] = 0.5
        du[1,2] = du[M,2] = 0
        for m=2:M-1
            du[m,1] = 1 - 1.45*(.5*u[m,1]+ .25*u[m-1,1] + .25u[m+1,1])^2 + 0.3*u[m,2]
            du[m,2] = u[m,1]
        end
        return nothing
    end
    return DiscreteDynamicalSystem(henon,rand(M,2), nothing; t0=0)
end


M=100
ds = coupled_henon(M)
N_train = 500
p = 20
data = trajectory(ds,N_train+p)
#Reconstruct this #
utrain = data[1:N_train,SVector(1:M...)]
utrain = map(state -> [state...], utrain)

vtrain = data[1:N_train,SVector(M+1:2M...)]
vtrain = map(state -> [state...], vtrain)
utest = data[N_train:N_train+p,SVector(1:M...)]
utest = map(state -> [state...], utest)
vtest = data[N_train:N_train+p,SVector(M+1:2M...)]
vtest = map(state -> [state...], vtest)


begin
    figure()
    ax1 = subplot(311)
    #Original
    pcolormesh(utest)
    colorbar()
    # Make x-tick labels invisible
    setp(ax1[:get_xticklabels](), visible=false)
    title("1D Coupled Henon Map")


    #Prediction
    ax2 = subplot(312, sharex = ax1, sharey = ax1)
    s_pred = localmodel_stts(utrain,2,1,p,1,1)#; boundary=false)
    pcolormesh(s_pred)
    colorbar()
    setp(ax2[:get_xticklabels](), visible=false)
    title("prediction ( N_train=$N_train)")
    ylabel("t")

    #Error
    ax3 = subplot(313, sharex = ax1, sharey = ax1)
    ε = [abs.(utest[i]-s_pred[i]) for i=1:p+1]
    pcolormesh(ε, cmap="inferno")
    colorbar()
    title("absolute error")
    xlabel("i = (x, y)")
    tight_layout()
end

#Cross-Prediction
begin
    figure()
    D = 2; τ = 1
    ax1 = subplot(221)
    #Original
    pcolormesh(utest[1+(D-1)τ:end])
    colorbar()
    # Make x-tick labels invisible
    setp(ax1[:get_xticklabels](), visible=false)
    title("Input U")

    ax2 = subplot(222, sharex = ax1, sharey = ax1)
    #Original
    pcolormesh(vtest[1+(D-1)τ:end])
    colorbar()
    # Make x-tick labels invisible
    setp(ax1[:get_xticklabels](), visible=false)

    title("1D Coupled Henon Map (V)")

    #Prediction
    ax3 = subplot(223, sharex = ax1, sharey = ax1)
    s_pred = crosspred_stts(utrain,vtrain, utest,D,τ,1,1,20, 0,0)
    pcolormesh(s_pred)
    colorbar()
    setp(ax2[:get_xticklabels](), visible=false)
    title("Cross-Pred U → V( N_train=$N_train)")
    ylabel("t")

    #Error
    ax4 = subplot(224, sharex = ax1, sharey = ax1)
    ε = [abs.(vtest[1+(D-1)τ:end][i]-s_pred[i]) for i=1:p]
    pcolormesh(ε, cmap="inferno")
    colorbar()
    title("absolute error")
    xlabel("x")
    tight_layout()
end

#Cross-Prediction
begin
    figure()
    D = 2; τ = 1
    ax1 = subplot(221)
    #Original
    pcolormesh(vtest[1+(D-1)τ:end])
    colorbar()
    # Make x-tick labels invisible
    setp(ax1[:get_xticklabels](), visible=false)
    title("Input V")

    ax2 = subplot(222, sharex = ax1, sharey = ax1)
    #Original
    pcolormesh(utest[1+(D-1)τ:end])
    colorbar()
    # Make x-tick labels invisible
    setp(ax1[:get_xticklabels](), visible=false)

    title("1D Coupled Henon Map (U)")

    #Prediction
    ax3 = subplot(223, sharex = ax1, sharey = ax1)
    s_pred = crosspred_stts(vtrain,utrain, vtest,D,τ,1,1,20, 0,0)
    pcolormesh(s_pred)
    colorbar()
    setp(ax2[:get_xticklabels](), visible=false)
    title("Cross-Pred V → U( N_train=$N_train)")
    ylabel("t")

    #Error
    ax4 = subplot(224, sharex = ax1, sharey = ax1)
    ε = [abs.(utest[1+(D-1)τ:end][i]-s_pred[i]) for i=1:p]
    pcolormesh(ε, cmap="inferno")
    colorbar()
    title("absolute error")
    xlabel("x")
    tight_layout()
end
