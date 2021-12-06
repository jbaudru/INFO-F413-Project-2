using Printf

# Print the formula in human readable form
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

function LasVegas(formula)

end

# Getting data from the cnf files
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


function main()
    # For each file in the folder
    formula = getData("cnf_example/uf20-01.cnf")
    readableCnf(formula)
end

main()
