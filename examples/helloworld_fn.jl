using BakerStreet
using DataFrames
using BakerStreet.DrWatson

function adder(;a, b)
    return (;c = a+b)
end

a = [1,2,3]
b = [10,20]

cfgs = DrWatson.dict_list(tostringdict((;a,b)))
BakerStreet.runsims(adder, cfgs, simname=@simname, filename=hash)

# df = @collect_results





println(@__FILE__)

function q2(x = @simname)
    println(x)
end