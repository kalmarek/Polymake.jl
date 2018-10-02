import Base: Set

import PolymakeWrap.Polymake.pm_Set

### convert TO polymake object

for (T, f) in [
    (Int32, :new_set_int32),
    (Int64, :new_set_int64),
    ]
    @eval begin
        function convert(::Type{Polymake.pm_Set}, v::Vector{$T})
            return Polymake.$f(v)
        end
    end
end

convert(::Type{Polymake.pm_Set}, s::Set{S}) where S = pm_Set(collect(s))

pm_Set{T}(v::Vector) where T = pm_Set(Vector{T}(v))
pm_Set{T}(s::Set) where T = pm_Set{T}(collect(s))

pm_Set(::Type{T}) where T = pm_Set{T}()

### convert FROM polymake object

function convert(::Type{Vector}, s::Polymake.pm_Set{T}) where T<:Integer
    return Vector{T}(s)
end

function convert(::Type{Vector{I}}, s::Polymake.pm_Set{J}) where {I,J<:Integer}
    return convert(Vector{I}, Vector(s))
end

for (T, f) in [
    (Int32, :fill_jlarray_int32_from_set32),
    (Int64, :fill_jlarray_int64_from_set64)
    ]
    @eval begin
        function convert(::Type{Vector{$T}}, s::Polymake.pm_Set{$T})
            v = Vector{$T}(length(s))
            Polymake.$f(v, s)
            return v
        end
    end
end

Set(s::Polymake.pm_Set{T}) where T = Set{T}(Vector(s))
Set{T}(s::Polymake.pm_Set{S}) where {T, S} = Set{T}(Vector{S}(s))

function convert(::Type{Set{T}}, set::Polymake.pm_Set{S}) where {T, S<:Integer}
    return Set{T}(Vector(set))
end

convert(::Polymake.pm_Set{T}, s::Polymake.pm_Set{T}) where T = s
convert(::Polymake.pm_Set{T}, s::Polymake.pm_Set) where T = s

### julia functions for sets


import Base.promote_rule
promote_rule(::Type{Set{S}}, ::Type{Polymake.pm_Set{T}}) where {S,T} = Set{promote_type(S,T)}

import Base: ==, hash, copy, similar, promote_rule
# comparison between not-equally typed sets is not defined in Polymake
==(S::Polymake.pm_Set, T::Polymake.pm_Set) = incl(S,T) == 0

function ==(S::Polymake.pm_Set, jlS::Set)
    length(S) == length(jlS) || return false
    for s in jlS
        s in S || return false
    end
    return true
end

==(T, S::Polymake.pm_Set) = S == T

hash(S::Polymake.pm_Set, h::UInt) = hash(Vector(S), h)

copy(s::Polymake.pm_Set) = deepcopy(s)

similar(S::Polymake.pm_Set{T}) where T = pm_Set(Vector{T}(length(S)))

# Iteration protocol

import Base: start, next, done, eltype

Base.start(S::pm_Set) = Polymake.begin(S)

function Base.next(S::pm_Set, state)
    elt = Polymake.get_element(state)
    return elt, state
end

Base.done(S::pm_Set, state) = Polymake.isdone(S, state)

eltype(::Type{Polymake.pm_Set{T}}) where T = T

# length : Defined on the C++ side

# Utility functions:
# isempty : Defined on the C++ side
# in : Defined on the C++ side


# Set operations:

import Base: pop!, union, intersect, unique, allunique

# push! : Defined on the C++ side
# delete! : Defined on the C++ side
# empty! : Defined on the C++ side

#in doubt: sizehint!, rehash!

function pop!(s::Polymake.pm_Set{T}, x) where T
    if x in s
        delete!(s, x)
        return x
    else
        throw(KeyError(x))
    end
end

pop!(s::Polymake.pm_Set{T}, x, default) where T = (x in s ? pop!(s, x) : default)
pop!(s::Polymake.pm_Set{T}) where T = (x = first(s); delete!(x, s); x)

union(s::Polymake.pm_Set) = copy(s)
intersect(s::Polymake.pm_Set) = copy(s)

unique(s::Polymake.pm_Set) = copy(s)
allunique(s::Polymake.pm_Set) = true

# Ordering:

import Base: <, <=

<(S::Polymake.pm_Set, T::Polymake.pm_Set) = incl(S,T) == -1
<=(S::Polymake.pm_Set, T::Polymake.pm_Set) = incl(S,T) <= 0