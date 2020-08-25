module MyAStar

# forked from https://github.com/JuliaAttic/Graphs.jl/blob/master/src/a_star_spath.jl
# under the MIT licence

# The enqueue! and dequeue! methods defined in Base.Collections (needed for
# PriorityQueues) conflict with those used for queues. Hence we wrap the A*
# code in its own module.

using Graphs
using DataStructures

# export shortest_path

mkindx(t) = typeof(t) == Int ? t : t.index

function a_star_impl!(
    graph::AbstractGraph{V},# the graph
    frontier,               # an initialized heap containing the active vertices
    colormap::Vector{Int},  # an (initialized) color-map to indicate status of vertices
    edge_dists::AbstractEdgePropertyInspector{D},  # cost of each edge
    heuristic::Function,    # heuristic fn (under)estimating distance to target
    targets::Array{V}) where {V,D} # the end vertex

    n = length(targets)
    i = 1
    tindx = mkindx(targets[i])
    tindx_last = mkindx(targets[end])
    the_best = nothing

    # última ruta sacada de la cola de prioridad
    path = nothing
    while !isempty(frontier)
        (cost_so_far, path, u) = DataStructures.dequeue!(frontier)

        uindx = mkindx(u)
        if uindx == tindx_last # ultimo nodo objetivo encontrado?

            # cuantifica si "path" esta seguiendo la restricción en orden
            # para asegurar monotonía (OJO no es la función heuristica, se usa esa misma
            # función para simplificar del código)
            cost_so_far = heuristic(0, 0, path)

            # guarda la mejor ruta encontrada hasta el momento
            if isnothing(the_best) || the_best[1] > cost_so_far
                the_best = (cost_so_far, path)
            end

            # evita seguir visitando nodos más allá de encontrar el vertice objetivo
            continue

        elseif i < n && uindx == tindx # ¿encontré el nodo local objetivo?
            # Cambia de objetivo y actualiza el costo respecto a la restricción
            i += 1
            tindx = mkindx(targets[i])


            # cuantifica si "path" esta seguiendo la restricción en orden
            # para asegurar monotonía (OJO no es la función heuristica, se usa esa misma
            # función con fines de simplicidad del código)
            cost_so_far = heuristic(0, 0, path)


        elseif u in targets
            # evita visitar vértices no consecutivos
            continue

        end

        for edge in out_edges(u, graph)
            v = target(edge)
            vindx = mkindx(v)
            if colormap[vindx] < 2
                colormap[vindx] = 1
                new_path = cat(path, edge, dims=1)
                path_cost = cost_so_far + edge_property(edge_dists, edge, graph)
                DataStructures.enqueue!(frontier,
                        (path_cost, new_path, v),
                        path_cost + heuristic(vindx, tindx))
            end
        end
        colormap[uindx] = 2
    end

    if !isnothing(the_best)
        return the_best[2]
    end

    @warn "Ruta óptima monónotona no econtrada"
    path
end


function shortest_path(
    graph::AbstractGraph{V,E},  # the graph
    edge_dists::AbstractEdgePropertyInspector{D},      # cost of each edge
    s::V,                       # the start vertex
    t::Array{V},                       # the end vertex
    heuristic::Function = n -> 0) where {V,E,D} # heuristic (under)estimating distance to target
    #
    frontier = DataStructures.PriorityQueue{Tuple{D,Array{E,1},V},D}()
    # frontier = DataStructures.PriorityQueue(Tuple{D,Array{E,1},V},D)
    frontier[(zero(D), E[], s)] = zero(D)
    colormap = zeros(Int, num_vertices(graph))
    sindx = mkindx(s)
    colormap[sindx] = 1
    a_star_impl!(graph, frontier, colormap, edge_dists, heuristic, t)
end

function shortest_path(
    graph::AbstractGraph{V,E},  # the graph
    edge_dists::Vector{D},      # cost of each edge
    s::V,                       # the start vertex
    t::Array{V},                       # the end vertex
    heuristic::Function = (n, m) -> 0 )  where {V,E,D}
    #
    edge_len::AbstractEdgePropertyInspector{D} = VectorEdgePropertyInspector(edge_dists)
    shortest_path(graph, edge_len, s, t, heuristic)
end


end

# using .AStar
