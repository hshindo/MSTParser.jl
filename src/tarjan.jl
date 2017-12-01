export tarjan

mutable struct Node
    id::Int
    index::Int
    lowlink::Int
    onstack::Bool
    tails::Vector{Node}
end

doc"""
    tarjan(heads::Vector{Int})

Computes Tarjan's algorithm for finding strongly connected components (cycles) of a graph.

# Example
```julia
heads = [3, 4, 2, 1, 4, 5]
tarjan(heads)
```
"""
function tarjan(heads::Vector{Int})
    for h in heads
        1 <= h <= length(heads) || throw("Invalid input: $h")
    end

    nodes = [Node(i,0,0,false,Node[]) for i=1:length(heads)]
    for i = 1:length(heads)
        push!(nodes[heads[i]].tails, nodes[i])
    end
    stack = Node[]
    cycles = Vector{Int}[]
    index = 1
    function strongconnect!(node::Node)
        node.index = index
        node.lowlink = index
        index += 1
        push!(stack, node)
        node.onstack = true

        for t in node.tails
            if t.index == 0
                # Successor t has not yet been visited
                strongconnect!(t)
                node.lowlink = min(node.lowlink, t.lowlink)
            elseif t.onstack
                # Successor t is in stack and hence in the current SCC
                node.lowlink = min(node.lowlink, t.index)
            end
        end

        # If node is a root, pop the stack and generate an SCC
        if node.lowlink == node.index
            cycle = Int[]
            while true
                t = pop!(stack)
                t.onstack = false
                push!(cycle, t.id)
                t == node && break
            end
            length(cycle) > 1 && push!(cycles,sort!(cycle))
        end
    end

    for node in nodes
        node.index == 0 && strongconnect!(node)
    end
    cycles
end
