const SmallObject = Union{pm_Integer, pm_Rational, pm_Matrix, pm_Vector, pm_Set, pm_Array}

const TypeConversionFunctions = Dict(
    Symbol("int") => to_int,
    Symbol("double") => to_double,
    Symbol("bool") => to_bool,
    Symbol("std::string") => to_string,
    Symbol("undefined") => x -> nothing,
)

function fill_wrapped_types!(wrapped_types_dict, function_type_list)
    function_names = function_type_list[1:2:end]
    type_names = function_type_list[2:2:end]
    for (fn, tn) in zip(function_names, type_names)
        fns = Symbol(fn)
        tn = replace(tn," "=>"")
        @eval $wrapped_types_dict[Symbol($tn)] = Polymake.$fns
    end
    return wrapped_types_dict
end

fill_wrapped_types!(TypeConversionFunctions, get_type_names())
