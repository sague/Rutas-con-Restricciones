using LinearAlgebra: norm
import Random: seed!
import Printf: @printf

rows = cols = 10

include("tools.jl")
include("problemas-de-prueba.jl")
include("a_star.jl")


is_visited(i, visitados) = begin
    a = !isnothing(findfirst( e -> i == e.source || i == e.target, visitados ))
    # @show a
    a
end

function distancia(ruta_generada, ruta_dada)
    L = Int[]
    for e in ruta_generada
        i = findfirst(a -> a == e, ruta_dada)
        if !isnothing(i)
            push!(L, i)
        end
    end

    k = 0
    for i in 2:length(L)
        if L[i-1] <= L[i] && L[i-1] == L[i] - 1
            k += 1
        end
    end

    # = 10(vértices en la restricción) - 10(vértices en la restricción visitados que son monónotonos crecientes )
    return 10length(ruta_dada) - 10k


end

function ruta_corta(grafo, distancias, ruta_dada_i, ruta_dada_x_y; penalización = 500)

    vértices_en_restricción = length(ruta_dada_i)

    h(vértice_actual::Int, vértice_objetivo, ruta_generada = nothing) = begin

        # calcula la función heuristica
        if isnothing(ruta_generada)
            A = index2coor_(vértice_actual, cols=cols, rows=rows)
            B = index2coor_(vértice_objetivo, cols=cols, rows=rows)
            d = norm( A - B )
            return round(Int, penalización*d)

        end

        # calcula el costo de la ruta_generada
        # (OJO esto no es parte de la función heurística)
        r = Int[]
        push!(r, source(ruta_generada[1]))
        for v in ruta_generada
            push!(r, target(v))
        end

        d = distancia(r, ruta_dada_i)

        return round(Int, d)
    end


    r = MyAStar.shortest_path(grafo, distancias, ruta_dada_i[1], ruta_dada_i[2:end], h)


    return r
end




function main(ejemplo=:espiral; p_obstaculo = 0.1, penalización = 500, seed_malla = 1, genera_gif=false)
    # clearconsole()
    seed!(seed_malla)
    grafo, distancias, nodos = genGrid(rows, cols; p = 1-p_obstaculo, M = nothing)

    if ejemplo == :espiral
        ruta_a_seguir_i, ruta_a_seguir_x_y = genera_espiral(nodos)
    elseif ejemplo == :seno
        ruta_a_seguir_i, ruta_a_seguir_x_y = genera_seno(nodos)
    elseif ejemplo == :parabola
        ruta_a_seguir_i, ruta_a_seguir_x_y = genera_parabola(nodos)
    elseif ejemplo == :puntos
        puntos = [
        1 1.0;
        1 6;
        2 8;
        3 10;
        6 9;
        8 8;
        5 6;
        8 5;
        5 4;
        9 1
        ]
        ruta_a_seguir_i, ruta_a_seguir_x_y  = genera_desde_puntos(nodos, puntos)
    else
        error("Valores validos: :espiral, :seno, :parabola, :puntos")
    end


    tic = time()
    r = ruta_corta(grafo, distancias, ruta_a_seguir_i, collect(ruta_a_seguir_x_y), penalización=penalización)
    toc = time() - tic
    @printf("Ruta calculada en: %.3f segundos\n", toc)
    println("Graficando...")

    #################################################
    ### grafica
    #################################################
    plotMalla(grafo, nodos; markersize=6)

    # plot!(espiral_x, espiral_y, color=:red)

    tmp = zeros(length(ruta_a_seguir_i), 2)
    for i in 1:length(ruta_a_seguir_i)
        tmp[i,:] = index2coor_(ruta_a_seguir_i[i], rows=rows, cols=cols)
    end

    if genera_gif
        println("Generando gif (Puede demorar un poco...)")
        @gif for i in 1:length(r)
            plot!(tmp[:,1], tmp[:,2], color=:orange, markershape=:o,linestyle = :dash, )
            plotTrayecotorias!(r[1:i], ruta_a_seguir_x_y, nodos)
        end
    else
        #################################################
        ### grafica
        #################################################
        i = length(r)
        plot!(tmp[:,1], tmp[:,2], color=:orange, markershape=:o,linestyle = :dash, )
        plotTrayecotorias!(r[1:i], ruta_a_seguir_x_y, nodos)
    end
end

# main(:espiral, seed_malla = 1, penalización = 500, genera_gif=false)
