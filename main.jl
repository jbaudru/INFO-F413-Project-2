# ==============================================================================
# BAUDRU Julien - 000460130
# Project 2 - December 2021
# INFO-F413 - Data structures and algorithm
# ==============================================================================

using Printf

# ==============================================================================
# Print the formula in human readable form
# ==============================================================================
function readableCnf(formula)
    formul = ""
    varname = Dict()
    for i = 1:26
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
function lasVegas(formula)
    # Assign random truth value to the variable
    varvalue = Dict()
    for i = 1:26
        varvalue[i] = rand((0, 1))
    end

    nb_satisf_clause = 0
    for i = 1:91
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
    println("Clauses satisf. : ", nb_satisf_clause, "/91")
    println("Success : ", nb_satisf_clause/91, " | Expected : ", 7/8)
    return nb_satisf_clause/91
end

# ==============================================================================
# Getting data from the cnf files
# ==============================================================================
function getData(filename)
    f = open(filename, "r")
    content = readlines(f)
    formula = zeros(Int, 91, 3)
    cmpt = 1; var_cmpt = 1
    for line in content
        if (length(line) > 2 && line[1] != 'c' && line[1] != 'p' && line[1] != '%' && line[1] != '0')
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
    close(f)
    return formula
end

# ==============================================================================
function main()
    # For each file in the folder
    formula = getData("cnf_example/uf20-01.cnf")
    #readableCnf(formula)
    nb_try = 1
    while (success = lasVegas(formula) < 7/8)
        nb_try += 1
    end
    println("Algorithm succeeded after ", nb_try, " tries.")
end

# ==============================================================================
main()
