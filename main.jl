# ==============================================================================
# BAUDRU Julien - 000460130
# Project 2 - December 2021
# INFO-F413 - Data structures and algorithm
# ==============================================================================

using Printf
using Plots

# ==============================================================================
# Getting data from the DIMACS format files
# ==============================================================================
function getData(filename)
    f = open(filename, "r")
    content::Vector{String} = readlines(f)
    formula = zeros(Int32, 91, 3)
    cmpt::UInt16 = 1; var_cmpt::UInt16 = 1; nb_clause::UInt16 = 0; nb_var::UInt16 = 0
    for line in content
        if (length(line) > 2 && line[1] != 'c' && line[1] != '%' && line[1] != '0')
            if (line[1] == 'p')
                lst::Vector{String} = split(line, ' ', keepempty=false)
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

# ==============================================================================
# Generate random truth value for the variables of a given formula
# ==============================================================================
function generateTruthValue(nb_var)
    varvalue = Dict()
    for i = 1:nb_var # Assign random truth value to the variable
        varvalue[i] = rand((0, 1))
    end
    return varvalue
end

# ==============================================================================
# Return a logical not for a given variable
# ==============================================================================
function getNotValue(var_name, var)
    if (var_name< 0) # If we want the NOT value of the variable
        if (var == 0) var = 1
        else var = 0
        end
    end
    return var
end

# ==============================================================================
# The famous algorithm
# ==============================================================================
function lasVegas(formula, nb_clause, nb_var)
    varvalue = generateTruthValue(nb_var)
    nb_satisf_clause::Int32 = 0
    for i = 1:nb_clause
        var::Int32 = varvalue[abs(formula[i, 1])]
        var = getNotValue(formula[i,1], var) # If we want the NOT value of the variable
        isClauseSatisfied::Int32 = 0 # At the beginning the clause is not satisfied
        for k in 2:3
            var = varvalue[abs(formula[i, k])]
            var = getNotValue(formula[i,k], var) # If we want the NOT value of the variable
            isClauseSatisfied |= var
        end
        if (isClauseSatisfied == 1)
            nb_satisf_clause += 1
        end
    end
    return nb_satisf_clause
end

# ==============================================================================
# Run the famous algorithm
# ==============================================================================
function lasVegasRunner(formula, nb_clause, nb_var)
    nb_try::Int32 = 1
    current_satisf_clause::Float32 = lasVegas(formula, nb_clause, nb_var)
    sum_nb_satisf_clause::Float32 = 0
    while (current_satisf_clause < (7*nb_clause)/8) # New truth assignement
        current_satisf_clause = lasVegas(formula, nb_clause, nb_var)
        nb_try += 1
        sum_nb_satisf_clause += current_satisf_clause
    end
    return current_satisf_clause, nb_try
end

# ==============================================================================
# Main loop : Run the algo. on multiples files and plots the results
# ==============================================================================
function main()
    filename_tmp = "data/uf20-91/"
    nb_file = 1000
    xx = zeros(0); x = zeros(0); y = zeros(0); z = zeros(0); w = zeros(0)
    sum_time::Float32 = 0; sum_success::Float32 = 0; sum_try::Float32 = 0; sum_clause::Float32 = 0
    for i=1:nb_file # For each file in the folder
        if (i!=266)
            filename = filename_tmp * "uf20-0" * string(i) * ".cnf"
            formula, nb_clause::Int32, nb_var::Int32 = getData(filename)
            print("Nb. variables : "); printstyled(100; color = :yellow)
            print("\nNb. clauses : "); printstyled(string(nb_clause) * "\n"; color = :yellow)
            println("   - File : ", filename)
            tmp_time = @elapsed lasVegasRunner(formula, nb_clause, nb_var)
            sum_time += tmp_time
            tmp_success, tmp_try = lasVegasRunner(formula, nb_clause, nb_var)
            sum_success += tmp_success
            sum_try += tmp_try
            sum_clause += nb_clause
            println("   Results :")
            printstyled("       Time : "; color = :green); print(tmp_time)
            printstyled("\n       Nb. satis. clauses : ", color = :green); print(tmp_success); print("/"* string(nb_clause))
            printstyled("\n       E[X] = 0.875 : ", color = :green); print(tmp_success/nb_clause)
            printstyled("\n       Trial(s) : ", color = :green); print(tmp_try)
            println("\n")
            append!(xx, i)
            append!(y, tmp_time)
            append!(z, tmp_success)
            append!(w, tmp_success/nb_clause)
        end
    end
    println("\nResults algorithm :")
    printstyled("   Avg. time : "; color = :green); print(sum_time/nb_file)
    printstyled("\n   Avg. satis. clauses : ", color = :green); print(sum_success/nb_file)
    printstyled("\n   E[X] = 0.875 : ", color = :green); print((sum_success/nb_file)/(sum_clause/nb_file))
    printstyled("\n   Avg. try : ", color = :green); print(sum_try/nb_file)
    println("\n")
    plot(xx, z, linecolor = :red, title = "Num. of satisfied clauses per instance", xlabel = "File number", ylabel = "Success")
    savefig("img/results4.png")
    plot(xx, y, linecolor = :red, title = "Running time per instance", xlabel = "File number", ylabel = "Time in sec.")
    savefig("img/results5.png")

end


main()
