module PolymakeWrap

module Polymake

    const foo = 1

    import Base: ==,
        append!,
        delete!, denominator,
        empty!,
        getindex,
        in, intersect, intersect!, isempty,
        length,
        numerator,
        push!,
        setdiff, setdiff!, setindex!, symdiff, symdiff!,
        union, union!

    using CxxWrap

    @static if Sys.isapple()
        @wrapmodule(joinpath(@__DIR__, "..", "deps", "src", "libpolymake.dylib"),
            :define_module_polymake)
    elseif Sys.islinux()
        @wrapmodule(joinpath(@__DIR__, "..", "deps", "src", "libpolymake.so"),
            :define_module_polymake)
    else
        error("System is not supported!")
    end

    function __init__()
        @initcxx
    end
end

polymake_c_types = Array{Any,1}([
   ("pm_perl_PropertyValue",Polymake.pm_perl_PropertyValue),
   ("pm_perl_OptionSet",Polymake.pm_perl_OptionSet),
   ("pm_perl_Object",Polymake.pm_perl_Object),
   ("pm_Integer",Polymake.pm_Integer),
   ("pm_Rational",Polymake.pm_Rational),
   ("pm_Matrix_pm_Integer",Polymake.pm_Matrix{Polymake.pm_Integer}),
   ("pm_Matrix_pm_Rational",Polymake.pm_Matrix{Polymake.pm_Rational}),
   ("pm_Vector_pm_Integer",Polymake.pm_Vector{Polymake.pm_Integer}),
   ("pm_Vector_pm_Rational",Polymake.pm_Vector{Polymake.pm_Rational}),
   ("pm_Set_Int64",Polymake.pm_Set{Int64}),
   ("pm_Set_Int32",Polymake.pm_Set{Int32}),
   ("pm_Array_Int32",Polymake.pm_Array{Int32}),
   ("pm_Array_Int64",Polymake.pm_Array{Int64}),
])

function set_types()
    for current_entry in polymake_c_types
        name = current_entry[1]
        current_type = Ptr{Cvoid}(pointer_from_objref(current_entry[2]))
        Polymake.set_julia_type(name,current_type)
    end
end

function __init__()
    Polymake.init()
    Polymake.application("polytope")
    set_types()
end

for T in [
    :pm_Integer,
    :pm_Rational,
    :pm_Matrix,
    :pm_Vector,
    :pm_Set,
    :pm_Array,
    :exists,
    :new_pm_Integer,
    :application,

    :swap,
    :incl,

    :range,
    :sequence,
    :scalar2set,

]
    @eval begin
        const $T = Polymake.$T
    end
end

const SmallObject = Union{Polymake.pm_Integer,
                          Polymake.pm_Rational,
                          Polymake.pm_Matrix,
                          Polymake.pm_Vector,
                          Polymake.pm_Set,
                          Polymake.pm_Array
                          }

include("functions.jl")
include("convert.jl")
include("sets.jl")
include("arrays.jl")

# to be moved to Vectors/Matrices
pm_Integer(b::BigInt) = new_pm_Integer(b)
pm_Rational(num::BigInt, den::BigInt) = pm_Rational(pm_Integer(num), pm_Integer(den))

Base.size(v::pm_Vector) = (length(v),)
Base.size(m::pm_Matrix) = (Polymake.rows(m), Polymake.cols(m))

function Base.getindex(V::pmV, n::Integer) where pmV <: pm_Vector 
    1 <= n <= length(V) || throw(BoundsError(V, n))
    Polymake._getindex(V, n)
end
function Base.setindex!(V::pmV, val, n::Int) where {T, pmV <: pm_Vector{T}}
    1 <= n <= length(V) || throw(BoundsError(V, n))
    return Polymake._setindex!(V, T(val), n)
end
end
