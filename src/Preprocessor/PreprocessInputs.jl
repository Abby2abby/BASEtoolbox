#---------------------------------------------------------
# Pre-process aggregate-model and steady-state inputs and write 
# them into the respective functions.
#---------------------------------------------------------

println("Preprocessing Inputs ...")

# aggregate model
model_template_file = open("Preprocessor/template_fcns/FSYS_agg.jl")
model_template_lines = readlines(model_template_file)
insert_index = findall(x -> x == "    # aggregate model marker", model_template_lines)[1]

model_input_file = open("Model/input_aggregate_model.jl")
model_input_text = read(model_input_file, String)
model_input_file = open("Model/input_aggregate_model.jl")
model_input_lines = readlines(model_input_file)

deblank(S::String) = filter(x -> !isspace(x), S)
number_of_equations =
    length(collect(eachmatch(r"F\[indexes.", deblank(model_input_text)))) -
    length(collect(eachmatch(r"\#F\[indexes.", deblank(model_input_text))))

open("Preprocessor/generated_fcns/FSYS_agg_generated.jl", "w") do h
    println(
        h,
        "# This file has been automatically generated by PreprocessInputs.jl. Any user inputs might be overwritten!",
    )
    println(h, "\n")

    println(h, "\n")
    for i = 1:insert_index-1
        println(h, model_template_lines[i])
    end
    println(h, "\n")
    for i in model_input_lines  # input the model text
        if occursin("@R", i)    # if there is a repetition marker create replications
            n1      = findfirst("@R", i)
            rsym    = i[n1[end]+1]
            n2      = findfirst(" ", i[n1[end]+1:end])
            repl    = parse(Int,i[n1[end]+2:n1[end]+n2[end]])
            for j = 1:repl
                line = i[n1[end]+n2[end]+1:end]
                line = replace(line, rsym => string(j)) 
                println(h, line)
            end
            if occursin("F[indexes.", i)
                number_of_equations += repl-1
            end
        else
            println(h, i)
        end
    end
    println(h, "\n")
    for i = insert_index+1:length(model_template_lines)
        println(h, model_template_lines[i])
    end
end
close(model_template_file)
close(model_input_file)

# aggregate steady state
SS_template_file    = open("Preprocessor/template_fcns/prepare_linearization.jl")
SS_template_lines   = readlines(SS_template_file)
insert_index        = findall(x -> x == "    # aggregate steady state marker", SS_template_lines)[1]

SS_input_file       = open("Model/input_aggregate_steady_state.jl")
SS_input_text       = read(SS_input_file, String)
SS_input_file       = open("Model/input_aggregate_steady_state.jl")
SS_input_lines      = readlines(SS_input_file)

open("Preprocessor/generated_fcns/prepare_linearization_generated.jl", "w") do h
    println(
        h,
        "# This file has been automatically generated by PreprocessInputs.jl. Any user inputs might be overwritten!",
    )
    println(h, "\n")

    for i = 1:insert_index-1
        println(h, SS_template_lines[i])
    end
    println(h, "\n")
    println(h, "@set! n_par.n_agg_eqn = $number_of_equations")
    for i in SS_input_lines  # input the model text
        if occursin("@R", i)    # if there is a repetition marker create replications
            n1      = findfirst("@R", i)
            rsym    = i[n1[end]+1]
            n2      = findfirst(" ", i[n1[end]+1:end])
            repl    = parse(Int,i[n1[end]+2:n1[end]+n2[end]])
            for j = 1:repl
                line = i[n1[end]+n2[end]+1:end]
                line = replace(line, rsym => string(j)) 
                println(h, line)
            end
        else
            println(h, i)
        end
    end
    println(h, "\n")
    for i = insert_index+1:length(SS_template_lines)
        println(h, SS_template_lines[i])
    end

end
close(SS_template_file)
close(SS_input_file)

println("Done!")
