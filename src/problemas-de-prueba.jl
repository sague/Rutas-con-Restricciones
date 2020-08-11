coor_2_index(x, y, rows, cols) = x%(rows+1) + (y-1)*cols



# elimina vertices en obstaculos
function elimina_en_obstaculos!(ruta_a_seguir_i, nodos)
    rows, cols = size(nodos)
    obstaculos = findall(n -> n == 0, reshape(nodos, rows*cols, 1)[:,1])
    del = Int[]
    for i in 1:length(ruta_a_seguir_i)
        if ruta_a_seguir_i[i] in obstaculos
            push!(del, i)
        end
    end

    deleteat!(ruta_a_seguir_i, del)
end


function genera_espiral(nodos)
    rows, cols = size(nodos)

    vueltas_espiral = 2.25
    tamaño_ruta_a_seguir = round(Int, 100*vueltas_espiral)

    θ = range(0, vueltas_espiral*2π, length=tamaño_ruta_a_seguir)
    r_x = 0.4rows / (vueltas_espiral*2π)
    r_y = 0.4cols / (vueltas_espiral*2π)
    espiral_x = 0.5rows .+ r_x*cos.(-θ) .* θ
    espiral_y = 0.5cols .+ r_y*sin.(-θ) .* θ

    ruta_a_seguir_x_y = (zip(espiral_x, espiral_y))
    ruta_a_seguir_i = unique([ coor_2_index(round.(coor)..., rows, cols) for coor in ruta_a_seguir_x_y ])
    ruta_a_seguir_i = reverse(round.(Int, ruta_a_seguir_i))

    # elimina vertices en obstaculos
    elimina_en_obstaculos!(ruta_a_seguir_i, nodos)


    ruta_a_seguir_x_y = hcat([ [c...] for c in ruta_a_seguir_x_y ]...)'


    return ruta_a_seguir_i, ruta_a_seguir_x_y
end

function genera_parabola(nodos)
    rows, cols = size(nodos)

    x = collect(range(1, cols, length = 100))
    y = 1 .+ (rows-1)*((-cols .+ 2x .- 1)/cols).^2

    ruta_a_seguir_x_y = (zip(x, y))
    ruta_a_seguir_i = unique([ coor_2_index(round.(coor)..., rows, cols) for coor in ruta_a_seguir_x_y ])
    ruta_a_seguir_i = reverse(round.(Int, ruta_a_seguir_i))

    # elimina vertices en obstaculos
    elimina_en_obstaculos!(ruta_a_seguir_i, nodos)
    ruta_a_seguir_x_y = hcat([ [c...] for c in ruta_a_seguir_x_y ]...)'


    return ruta_a_seguir_i, ruta_a_seguir_x_y

end

function genera_seno(nodos)
    rows, cols = size(nodos)

    x = collect(range(0, 2π, length = 100))
    y = 1 .+ 0.4(rows-1)*(1 .+ sin.(x))
    x = 1 .+ (cols-1)*(x/2π)

    ruta_a_seguir_x_y = (zip(x, y))
    ruta_a_seguir_i = unique([ coor_2_index(round.(coor)..., rows, cols) for coor in ruta_a_seguir_x_y ])
    ruta_a_seguir_i = reverse(round.(Int, ruta_a_seguir_i))

    # elimina vertices en obstaculos
    elimina_en_obstaculos!(ruta_a_seguir_i, nodos)
    ruta_a_seguir_x_y = hcat([ [c...] for c in ruta_a_seguir_x_y ]...)'


    return ruta_a_seguir_i, ruta_a_seguir_x_y

end

function genera_desde_puntos(nodos, puntos)
    rows, cols = size(nodos)

    x, y = puntos[:,1], puntos[:,2]

    ruta_a_seguir_x_y = (zip(x, y))
    ruta_a_seguir_i = unique([ coor_2_index(round.(coor)..., rows, cols) for coor in ruta_a_seguir_x_y ])
    ruta_a_seguir_i = reverse(round.(Int, ruta_a_seguir_i))

    # elimina vertices en obstaculos
    elimina_en_obstaculos!(ruta_a_seguir_i, nodos)
    ruta_a_seguir_x_y = hcat([ [c...] for c in ruta_a_seguir_x_y ]...)'


    return ruta_a_seguir_i, ruta_a_seguir_x_y

end
