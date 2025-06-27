module BakerStreet

using DrWatson
using MacroTools

export runsims, loadsims, getrow
export @runsims, @simname, @collect_results

function strdict_expr_from_vars(vars)
    expr = Expr(:call, :Dict)
    for var in vars
        # Allow assignment syntax a = b
        if @capture(var, a_ = b_)
            push!(expr.args, :($(string(a)) => $(esc(b))))
        # Allow single arg syntax a   → "a" = a
        elseif @capture(var, a_Symbol)
            push!(expr.args, :($(string(a)) => $(esc(a))))
        else
            return :(throw(ArgumentError("Invalid field syntax")))
        end
    end
    return expr
end

function fn_pars_hash(config)
    bn = DrWatson.savename(config)
    hs = hash(config)
    fn = string(bn, "_", hs)
    return fn
end

function runsims(f, configs; simname, force=false, kwargs...)
    path = datadir(simname)
    for config in configs
        _, file = produce_or_load(config, path;
            loadfile=false,
            filename=fn_pars_hash(config),
            force,
            kwargs...) do cfg

            config_nt = dict2ntuple(config)
            results_nt = f(;config_nt...)
            data_strdict = merge(config, tostringdict(results_nt))
        end
    end
    return loadsims(simname, configs)
end

function runsims(f, simname::String; force=false, kwargs...)
    param_ranges_symdict = Dict{Symbol,Any}(k => kwargs[k] for k in keys(kwargs))
    configs_symdict = DrWatson.dict_list(param_ranges_symdict)
    configs_strdict = [DrWatson.tostringdict(cf) for cf in configs_symdict]
    runsims(f, configs_strdict; simname, force)
end

macro runsims(f, vars...)
    expr = strdict_expr_from_vars(vars)
    fn = string(__source__.file)
    rp = dirname(relpath(fn, projectdir()))
    sn = splitext(basename(fn))[1]
    path = joinpath(rp, sn)
    r = :(runsims($(esc(f)), dict_list($(expr)); simname=$(path)))
    return r
end

macro runsims_force(f, vars...)
    expr = strdict_expr_from_vars(vars)
    fn = string(__source__.file)
    rp = dirname(relpath(fn, projectdir()))
    sn = splitext(basename(fn))[1]
    path = joinpath(rp, sn)
    r = :(runsims($(esc(f)), dict_list($(expr)); simname=$(path), force=true))
    println(r)
    return r
end

macro simname()
    :($(splitext(basename(string(__source__.file)))[1]))
end

macro collect_results()
    fn = string(__source__.file)
    rp = dirname(relpath(fn, projectdir()))
    sn = splitext(basename(fn))[1]
    path = joinpath(rp, sn)
    xp = :(collect_results(datadir($(path))))
end

function loadsims(simname, configs=nothing)
    
    df = DrWatson.collect_results(datadir(simname))
    configs == nothing && return df

    df = filter!(df) do row
        for config in configs
            config_found = true
            for (k,v) in pairs(config)
                row[k] != v && (config_found = false) && break
            end
            config_found && return true
        end
        return false
    end
end

function getrow(df; kwargs...)
    for row in eachrow(df)
        match = true
        for (k,v) in kwargs
            if !(row[k] ≈ v)
                match = false
                break
            end
        end
        match && return row
    end
    return nothing
end

end
