using Plots
using Graphs
pyplot(legend=false, size=(500, 500))
include("plot-malla.jl")

function evalPoly(a, xData, x)
    n = length(xData)  # Degree of polynomial
    p = a[n]
    for k =1:n-1
        p = a[n-k] + (x -xData[n-k])*p
    end
    return p

end

function coeffts(xData,yData)
    m = length(xData)  # Number of data points

    a = copy(yData)

    for k=2:m
        a[k:m] = (a[k:m] .- a[k-1]) ./ (xData[k:m] .- xData[k-1])
    end

    return a
end


function genGrid(rows, cols; p = 0.2, M = nothing)

	if M == nothing
    	M = zeros(Int, rows, cols)
    	M[ rand(rows, cols) .< p ] .= 1
	end


    # crea malla con nombre 1 a r*c
    #srand(543222423)


    grafo = simple_graph(rows * cols, is_directed = false)
    pesos = []

    for i = 1:rows*cols
        if M[i] == 0
            continue
        end
        if i > 1 && i%rows != 1 && M[i-1] == 1
            add_edge!(grafo, i, i-1)
            push!(pesos, 1 + 10rand())
        end
        if i > rows && M[i-cols] == 1
            add_edge!(grafo, i, i-cols)
            push!(pesos, 1 + 10rand())

        end
    end

    return grafo, ones(Int, length(pesos)), M
end

function genGridFromFile(fname)
    nodosMatriz = readcsv(fname)
    rows, cols = size(nodosMatriz, 1, 2)

    # crea malla con nombre 1 a r*c
    grafo = simple_graph(rows * cols, is_directed = false)
    pesos = []

    for i = 1:rows*cols
        if i > 1 && i%rows != 1 && nodosMatriz[i-1] == 1
            add_edge!(grafo, i, i-1)
            push!(pesos, 1 +2rand())
        end
        if i > rows && nodosMatriz[i-cols] == 1
            add_edge!(grafo, i, i-cols)
            push!(pesos, 1 + 2rand())

        end
    end

    return grafo, ones(Int, length(pesos)), nodosMatriz
end

function recta(x, a, b)
    x1 = a[1]
    x2 = b[1]

    y1 = a[2]
    y2 = b[2]

    m = (y2 - y1) / (x2 - x1)

    return m * (x - x1) + y1
end

function experimento(rows, cols, ini, fin, puntos)
    println("Iniciando")


    grafo, distancias, nodos = genGrid(rows, cols;p=0.7)



    inicio  = index2coor_(ini, rows=rows, cols=cols)
    destino = index2coor_(fin, rows=rows, cols=cols)

    println(inicio)
    println(destino)

    nodos[ini] = 1
    nodos[fin] = 1

    p  = puntos[1,:]
    p2 = puntos[2,:]

    # interpolar polinomio con 4 puntos
    data = [inicio';
            p';
            p2';
            destino']

    xData = data[:,1]
    yData = data[:,2]


    coef = coeffts(xData,yData)

    rutaGPS(x, coef_ = coef, xData_=xData) = (evalPoly(coef_, xData_, x))

    pol = zeros(Bool, rows*cols)


    # for i = 1:length(grafo.edges)
    #     x, y = index2coor_(target(grafo.edges[i]), cols=cols, rows=rows)
    #     if y == rutaGPS(x)
    #         distancias[i] = 0
    #     end

    #     x, y = index2coor_(source(grafo.edges[i]), cols=cols, rows=rows)
    #     if y == rutaGPS(x)
    #         distancias[i] = 0
    #     end
    # end

    h(t::Int) = begin
        x, y = index2coor_(t, cols=cols, rows=rows)
        d = abs(y - (rutaGPS(x)))

        if d > 1
            return round(Int, 100000d)
        end

        return round(Int,d)
    end

    println("Buscando ruta...")
    # ruta más corta usando A*
    @time r = shortest_path(grafo, distancias, ini, fin, h)
    if isnothing(r)
        error("ruta no encontrada en esa malla.")
    end
    println("Listo ", length(r))

    return grafo, nodos, rutaGPS, r


end

function test()

	rows = 20
	cols = 20

	ini = 1
	fin = rows * cols - 8
	puntos = [
	     5.0  23.0;
	    14.0   5.0
	]

	experimento(rows, cols, ini, fin, puntos)
end
