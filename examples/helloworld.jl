using BakerStreet
using DataFrames

function adder(;a, b)
    return (;c = a+b)
end

a = [1,2,3]
@runsims adder a b=[10,20]

df = @collect_results
