# BakerStreet

This package facilitates one of the many ways [DrWatson.jl](https://github.com/JuliaDynamics/DrWatson.jl) enables users to set up and run simulations, and to store and retrieve the results of these simulations.

The workflow targeted by `BakerStreet.jl` has the following structure:

```julia
using BakerStreet
using DataFrames

function adder(;a, b)
    return (;c = a+b)
end

a = [1,2,3]
@runsims adder a b=[10,20]

df = @collect_results
```

The simulation is started on by macro `@runsims`. A configuration is created and the payload method `adder` is called over the Cartesian product of parameter ranges `(a,b)`. The dictionary that is written to disk is the merge of the inputs and outputs of adder (so in this case the keys are `(a,b,c)`). The results are written in a subdirectory of `DrWatson.datadir()` with name `splitext(@__FILE__)[1]`. Likewise, `@collect_results` looks for output data in this directory.

The `DataFrame` created by `@collect_results` is:

```
 Row │ c       b       a       path
     │ Int64?  Int64?  Int64?  String?
─────┼───────────────────────────────────────────────────────────
   1 │     11      10       1  C:\\Users\\.julia\\dev\…
   2 │     21      20       1  C:\\Users\\.julia\\dev\…
   3 │     12      10       2  C:\\Users\\.julia\\dev\…
   4 │     22      20       2  C:\\Users\\.julia\\dev\…
   5 │     13      10       3  C:\\Users\\.julia\\dev\…
   6 │     23      20       3  C:\\Users\\.julia\\dev\…
```

Running this script results in the following directory contents:

```
│   helloworld.jl
│   Manifest.toml
│   Project.toml
│
└───data
    └───helloworld
            a=1_b=10.jld2
            a=1_b=20.jld2
            a=2_b=10.jld2
            a=2_b=20.jld2
            a=3_b=10.jld2
            a=3_b=20.jld2
```

This package can be seen as a template or recipe that encodes a very specific choice for the options and conventions that one can use when running simulations with DrWatson.jl.
