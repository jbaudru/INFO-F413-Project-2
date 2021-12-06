# ==============================================================================
# BAUDRU Julien - 000460130
# Project 2 - December 2021
# INFO-F413 - Data structures and algorithm
# ==============================================================================

using Printf
using Plots

# ==============================================================================
# Print the formula in human readable form
# ==============================================================================
function readableCnf(formula)
    formul = ""
    varname = Dict()
    for i = 1:26x
        c = Char(96 + i)
        varname[i] = c
    end
    for i = 1:91
        tmp_form = ""
        for k in 1:3
            if (formula[i, k] < 0) # NOT
                tmp_form*= "¬"
            end
            tmp_form *= string(varname[abs(formula[i, k])])
            if (k != 3)
                tmp_form *= " ∨ "
            end
        end
        formul *= "("
        formul *= tmp_form
        formul *= ")"
        if (i != 91)
            formul *= " ∧ "
        end
    end
    println(formul)
end

# ==============================================================================
function lasVegas(formula, nb_clause, nb_var)
    # Assign random truth value to the variable
    varvalue = Dict()
    for i = 1:nb_var
        varvalue[i] = rand((0, 1))
    end

    nb_satisf_clause = 0
    for i = 1:nb_clause
        var::UInt8 = varvalue[abs(formula[i, 1])]
        if (formula[i,1]< 0)
            if (var == 0) var = 1
            else var = 0
            end
        end
        isClauseSatisfied = var
        for k in 2:3
            var = varvalue[abs(formula[i, k])]
            if (formula[i,k]< 0)
                if (var == 0) var = 1
                else var = 0
                end
            end
            isClauseSatisfied |= var
        end
        if (isClauseSatisfied == 1)
            nb_satisf_clause += 1
        end
    end
    #println("Clauses satisf. : ", nb_satisf_clause, "/91")
    return nb_satisf_clause/nb_clause
end

# ==============================================================================
# Getting data from the cnf files
# ==============================================================================
function getData(filename)
    f = open(filename, "r")
    content = readlines(f)
    formula = zeros(Int, 91, 3)
    cmpt = 1; var_cmpt = 1
    nb_clause = 0; nb_var = 0
    for line in content
        if (length(line) > 2 && line[1] != 'c' && line[1] != '%' && line[1] != '0')
            if (line[1] == 'p')
                lst = split(line, ' ', keepempty=false)
                nb_clause = parse(Int64, lst[end])
                nb_var = parse(Int64, lst[3])
                formula = zeros(Int, nb_clause, 3)
            else
                for var in split(line, ' ', keepempty=false)
                    x = parse(Int64, var)
                    if (x!=0)
                        formula[cmpt, var_cmpt] = x
                        var_cmpt += 1
                    else
                        cmpt += 1
                        var_cmpt = 1
                    end
                end
            end
        end
    end
    close(f)
    return formula, nb_clause, nb_var
end

function lasVegasAll(formula, nb_clause, nb_var)
    nb_try = 1
    success = lasVegas(formula, nb_clause, nb_var)
    while (success < 7/8)
        success = lasVegas(formula, nb_clause, nb_var)
        nb_try += 1
    end
    return success
end

# ==============================================================================
function main()
    # For each file in the folder
    folder_dic = Dict{String, Integer}("0uf20-91/uf20-0" => 1000, "1uf50-218/uf50-0" => 1000, "2uf75-325/uf75-0" => 100, "3uf100-430/uf100-0" => 1000, "4uf125-538/uf125-0" => 100, "5uf150-645/uf150-0" => 100, "6uf175-753/uf175-0" => 100, "7uf200-860/uf200-0" => 100, "8uf225-960/uf225-0" => 100, "9uf250-1065/uf250-0" => 100)
    folder_dic = sort(collect(folder_dic))

    x = [20, 50, 75, 100, 125, 150, 175, 200, 225, 250]
    y = zeros(0)
    z = zeros(0)
    for (filename_tmp, nb_file) in folder_dic
        println("FOLDER : ",filename_tmp ," (", nb_file,")")
        avg_time = 0
        avg_success = 0
        for i=1:nb_file # For each file in the folder
            filename = filename_tmp * string(i) * ".cnf"
            formula, nb_clause, nb_var = getData(filename)
            #readableCnf(formula)
            avg_time += @elapsed lasVegasAll(formula, nb_clause, nb_var)
            avg_success += lasVegasAll(formula, nb_clause, nb_var)
        end
        println("   Avg. time : ", avg_time/nb_file)
        println("   Avg. success : ", avg_success/nb_file)
        println()
        append!(y, avg_time/nb_file)
        append!(z, avg_success/nb_file)
    end
    # TODO : Axes titles
    # TODO : Correct tick axes
    plot(x, z, title = "Average success by number of variable in 3SAT")
    savefig("results1.png")
    plot(x, y, title = "Average running time by number of variable in 3SAT")
    savefig("results2.png")
end

# ==============================================================================
main()
