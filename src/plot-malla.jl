index2coor_(i; rows = 0, cols=0) =  [i%(rows) < 1 ?  rows : i%(rows), i%(rows) < 1 ? div(i, cols) : 1 + div(i, cols)]

function plotMalla(grafo, nodos; markersize=5)
    p = Plots.plot(title="Gráfica")
    plotMalla!(grafo, nodos; markersize=markersize)
end

function plotMalla!(grafo, nodos; markersize=5)
    rows, cols = size(nodos)
    l = findall(Bool.(nodos)) #[ (e.source, e.target) for e in grafo.edges]
    x = map(z-> z[1], l)
    y = map(z-> z[2], l)

    for v in grafo.vertices
        nodos[v] == 0 && continue
        q = in_neighbors(v, grafo)
        isempty(q) && continue
        w = index2coor_(v, rows=rows, cols=cols)

        for vv in q
            nodos[vv] == 0 && continue

            z = index2coor_(vv, rows=rows, cols=cols)
            #(z[2] < 1 || w[2] < 1) && continue
            Plots.plot!([w[1], z[1]], [w[2], z[2]], color=:black)

        end
    end


    scatter!(x, y,  color=:white, markersize=markersize)
end

function plotTrayecotorias(r, rutaGPS_x_y, nodos; markersize=6)
    plotTrayecotorias!(r, rutaGPS_x_y, nodos; markersize=markersize)
end

function plotTrayecotorias!(r, rutaGPS_x_y, nodos; markersize=6)
    rows, cols = size(nodos)
    rr = zeros(length(r)+1, 2)
    i = 1
    for e in r
        w = index2coor_(source(e), rows=rows, cols=cols)
        # z = index2coor_(target(e), rows=rows, cols=cols)
        rr[i,:] = w
        i+=1
    end
    rr[end,:] = index2coor_(target(r[end]), rows=rows, cols=cols)

    Plots.plot!(rr[:,1], rr[:,2], color=:green, lw=5, alpha=0.5)

    Plots.plot!(rutaGPS_x_y[:,1], rutaGPS_x_y[:,2], marker=:o,color=:red, markersize=2, markerstrokewidth=0)
end
