using NPZ
using HDF5
using Base.Threads

function get_data(filename::String, Cutoff_Fields::Vector{String})
    data = Dict{String, Vector{Float64}}()
    file::HDF5.File = h5open(filename, "r")
    base_field::String = "PartType0/"
    for _field::String in Cutoff_Fields
        if _field == "Coordinates"
            Coordinates::Matrix{Float64} = read(file[base_field*_field])
            data["x"] = Coordinates[1,:]
            data["y"] = Coordinates[2,:]
            data["z"] = Coordinates[3,:]
        elseif _field == "Velocities"
            Velocities::Matrix{Float64} = read(file[base_field*_field])
            data["vx"] = Velocities[1,:]
            data["vy"] = Velocities[2,:]
            data["vz"] = Velocities[3,:]
        elseif _field == "GFM_Metals"
            GFM_Metals::Matrix{Float64} = read(file[base_field*_field])
            GFM_Metals_list::Vector{String} = ["H", "He", "C", "N", "O", "Ne", "Mg", "Si", "Fe", "Total"]
            for i::Int64 in 1:length(GFM_Metals_list)
                data[GFM_Metals_list[i]] = GFM_Metals[i,:]
            end
        else
            data[_field] = read(file[base_field*_field])
        end
    end
    return data
end

function cutoff(data::Dict{String, Vector{Float64}}, cutoff_data::Dict{String, Vector{Float64}}, cmx::Float64, cmy::Float64, cmz::Float64, cutoff_radius::Float64)
    _x::Vector{Float64} = data["x"]
    _y::Vector{Float64} = data["y"]
    _z::Vector{Float64} = data["z"]

    r::Vector{Float64} = sqrt.((_x .- cmx).^2 .+ (_y .- cmy).^2 .+ (_z .- cmz).^2)

    fields_list = collect(keys(data))
    for i::String in fields_list
        lock(lk) do
            cutoff_data[i] = vcat(cutoff_data[i], data[i][r .< cutoff_radius])
        end
    end
end


const Cutoff_Fields = ["Coordinates", "Velocities", "Masses", "GFM_Metals"]

cmx::Float64, cmy::Float64, cmz::Float64 = 25045.18, 5827.554, 34187.434

h::Float64 = 0.6774
virial_radius::Float64 = 194.9481
cutoff_radius::Float64 = virial_radius*h*10

file_list = readdir("../data/TNG50-1/output/snapdir_099/", join=true)
cutoff_data = Dict{String, Vector{Float64}}()
lk = ReentrantLock()

println("Threads ", Threads.nthreads())

data = get_data(file_list[1], Cutoff_Fields)
fields_list = collect(keys(data))
for j::String in fields_list
    cutoff_data[j] = Float64[]
end

@time @threads for i::Int64 in 1:length(file_list)
    data = get_data(file_list[i], Cutoff_Fields)
    cutoff(data, cutoff_data, cmx, cmy, cmz, cutoff_radius)
    println(i)
end

npzwrite("CVMM2.npz", cutoff_data)

println("Number of particles: ", length(cutoff_data["x"]))
println("DONE!")