# ==============================================================================
# BAUDRU Julien - 000460130
# Project 2 - December 2021
# INFO-F413 - Data structures and algorithm
# ==============================================================================

using Printf
using Plots

# ==============================================================================
# Getting data from the cnf files
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
function lasVegas(formula, nb_clause, nb_var)
    varvalue = Dict()
    for i = 1:nb_var # Assign random truth value to the variable
        varvalue[i] = rand((0, 1))
    end
    nb_satisf_clause::Int32 = 0
    for i = 1:nb_clause
        var::Int32 = varvalue[abs(formula[i, 1])]
        if (formula[i,1]< 0)
            if (var == 0) var = 1
            else var = 0
            end
        end
        isClauseSatisfied::Int32 = var
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
    return nb_satisf_clause/nb_clause
end

function lasVegasRunner(formula, nb_clause, nb_var)
    nb_try::Int32 = 1
    success::Float32 = lasVegas(formula, nb_clause, nb_var)
    while (success < 7/8)
        success = lasVegas(formula, nb_clause, nb_var)
        nb_try += 1
    end
    return success, nb_try
end

# ==============================================================================
function main()
    folder_dic = Dict{String, Integer}("data/0uf20-91/uf20-0" => 1000, "data/1uf50-218/uf50-0" => 1000, "data/2uf75-325/uf75-0" => 100, "data/3uf100-430/uf100-0" => 1000, "data/4uf125-538/uf125-0" => 100, "data/5uf150-645/uf150-0" => 100, "data/6uf175-753/uf175-0" => 100, "data/7uf200-860/uf200-0" => 100, "data/8uf225-960/uf225-0" => 100, "data/9uf250-1065/uf250-0" => 100)
    folder_dic = sort(collect(folder_dic))
    x = [20, 50, 75, 100, 125, 150, 175, 200, 225, 250]
    xx = [91, 218, 325, 430, 538, 645, 753, 860, 960, 1065]
    y = zeros(0); z = zeros(0); w = zeros(0) # tries
    cmpt::Int32 = 1
    for (filename_tmp, nb_file) in folder_dic
        println("Data : ", filename_tmp)
        print("Nb. variables : "); printstyled(x[cmpt]; color = :yellow)
        print("\nNb. clauses : "); printstyled(xx[cmpt]; color = :yellow)
        cmpt+=1
        avg_time::Float32 = 0; avg_success::Float32 = 0; avg_try::Float32 = 0
        for i=1:nb_file # For each file in the folder
            filename = filename_tmp * string(i) * ".cnf"
            formula, nb_clause::Int32, nb_var::Int32 = getData(filename)
            avg_time += @elapsed lasVegasRunner(formula, nb_clause, nb_var)
            tmp_success, tmp_try = lasVegasRunner(formula, nb_clause, nb_var)
            avg_success += tmp_success
            avg_try += tmp_try
        end
        append!(y, avg_time/nb_file)
        append!(z, avg_success/nb_file)
        append!(w, avg_try/nb_file)
        println("\nResults :")
        printstyled("   Avg. time : "; color = :green); print(avg_time/nb_file)
        printstyled("\n   Avg. success : ", color = :green); print(avg_success/nb_file)
        printstyled("\n   Avg. try : ", color = :green); print(avg_try/nb_file)
        println("\n")
    end
    # TODO : Add plot to report
    plot(x, z, xticks = x, title = "Average success per number of variable in 3SAT", xlabel = "Num. of var.", ylabel = "Avg. success")
    savefig("img/results1.png")
    plot(x, y, xticks = x, title = "Average running time per number of variable in 3SAT", xlabel = "Num. of var.", ylabel = "Avg. time")
    savefig("img/results2.png")
    plot(x, w, xticks = x, title = "Average number of trials per number of variable in 3SAT", xlabel = "Num. of var.", ylabel = "Avg. tries")
    savefig("img/results3.png")
    plot(xx, z, xticks = xx, title = "Average success per number of clause in 3SAT", xlabel = "Num. of clauses", ylabel = "Avg. success")
    savefig("img/results4.png")
    plot(xx, y, xticks = xx, title = "Average running time per number of clause in 3SAT", xlabel = "Num. of clauses", ylabel = "Avg. time")
    savefig("img/results5.png")
    plot(xx, w, xticks = xx, title = "Average number of trials per number of clause in 3SAT", xlabel = "Num. of clauses", ylabel = "Avg. tries")
    savefig("img/results6.png")
end


main()
