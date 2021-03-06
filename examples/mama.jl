using Strategems, Temporal, Indicators, Base.Dates
using Base.Test

# define universe and gather data
assets = ["CHRIS/CME_CL1", "CHRIS/CME_RB1"]
universe = Universe(["CHRIS/CME_CL1", "CHRIS/CME_RB1"])
gather!(universe)

# define indicators and parameter space
arg_names = [:fastlimit, :slowlimit]
arg_defaults = [0.5, 0.05]
paramset = ParameterSet(arg_names, arg_defaults)
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
backtest!(strat)
