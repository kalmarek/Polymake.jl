#ifndef POLYMAKE_WRAP_FUNCTIONS
#define POLYMAKE_WRAP_FUNCTIONS


void initialize_polymake();

polymake::perl::Object call_func_0args(std::string);

polymake::perl::Object call_func_1args(std::string, int);

polymake::perl::Object call_func_2args(std::string, int, int);

pm::perl::Object to_perl_object(pm::perl::PropertyValue);

template<typename T>
T to_SmallObject(pm::perl::PropertyValue pv){
    T obj = pv;
    return obj;
};

pm::Integer new_integer_from_bigint(jl_value_t*);

// We can do better templating here
template<typename T>
std::string show_small_object(const T& obj, bool print_typename = true){
    std::ostringstream buffer;
    auto wrapped_buffer = wrap(buffer);
    if (print_typename) {
        wrapped_buffer << polymake::legible_typename(typeid(obj)) << pm::endl;
    }
    wrapped_buffer << obj;
    return buffer.str();
}

#endif
