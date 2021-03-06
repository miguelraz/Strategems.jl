using Strategems, Temporal, Indicators, Base.Dates
using Base.Test

# define universe and gather data
assets = ["Corn"]
universe = Universe(assets)
@test universe.assets == assets
gather!(universe, source=(asset)->Temporal.tsread("$(Pkg.dir("Temporal"))/data/$asset.csv"))
@test length(setdiff(assets, collect(keys(universe.data)))) == 0

# define indicators and parameter space
arg_names = [:fastlimit, :slowlimit]
arg_defaults = [0.5, 0.05]
paramset = ParameterSet(arg_names, arg_defaults)
@test paramset.arg_names == arg_names
f(x; args...) = Indicators.mama(Temporal.hl2(x); args...)
indicator = Indicator(f, paramset)

# define signals
signals = Dict{Symbol,Signal}(:GoLong=>Signal(:(MAMA ↑ FAMA)),
                              :GoShort=>Signal(:(MAMA ↓ FAMA)))

# define the trading rule
rules = Dict{Symbol,Rule}(:EnterLong=>Rule(:GoLong, :(buy,asset,100)),
                          :EnterShort=>Rule(:GoShort, :(sell,asset,100)))

# strategy object
strat = Strategy(universe, indicator, signals, rules)
generate_trades!(strat)
backtest!(strat)
@test length(setdiff(collect(keys(strat.results["Backtest"])), universe.assets)) == 0
