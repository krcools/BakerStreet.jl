# Version 0.2.1

- `runsims` only loads files that correspond to the supplied parameter range, even when other files still exist in the simulation folder. 

# Version 0.2.0

- Simulation files are now saved to `joinpath(dirname(datadir(relpath(@__FILE__, projectdir()))), @simname)`. For example, a scripts at project relative path `scripts/example.jl` will save its outputs to project relative path `data/scripts/example/`.