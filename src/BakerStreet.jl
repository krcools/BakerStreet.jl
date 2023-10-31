module BakerStreet

using DrWatson
using MacroTools

export runsims, @runsims, @simname, @collect_results

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

function runsims(f, configs; simname, force=false)
    for config in configs
        @show config
        path = datadir(simname)
        _, file = produce_or_load(config, path; loadfile=false, force) do cfg
            config_nt = dict2ntuple(config)
            results_nt = f(;config_nt...)
            data_strdict = merge(config, tostringdict(results_nt))
        end
    end
end

macro runsims(f, vars...)
    expr = strdict_expr_from_vars(vars)
    simname = splitext(basename(string(__source__.file)))[1]
    r = :(runsims($(esc(f)), dict_list($(expr)); simname=$(simname)))
    println(r)
    return r
end

macro runsims_force(f, vars...)
    expr = strdict_expr_from_vars(vars)
    simname = splitext(basename(string(__source__.file)))[1]
    r = :(runsims($(esc(f)), dict_list($(expr)); simname=$(simname), force=true))
    println(r)
    return r
end

macro simname()
    :($(splitext(basename(string(__source__.file)))[1]))
end

macro collect_results()
    xp = :(collect_results(datadir($(splitext(basename(string(__source__.file)))[1]))))
end

end
