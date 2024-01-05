using NPZ

file_list = readdir("./AllOfData_CMVonly")

cmx::Float64, cmy::Float64, cmz::Float64 = 25045.18, 5827.554, 34187.434

x, y, z, vx, vy, vz, m = Float64[], Float64[], Float64[], Float64[], Float64[], Float64[], Float64[]


h::Float64 = 0.6774
virial_radius::Float64 = 194.9481
cutoff_radius::Float64 = virial_radius*h*10

for i::Int64 in 1:length(file_list)
    global x, y, z, vx, vy, vz, m
    data = npzread( "./AllOfData_CMVonly/" * file_list[1])

    _x::Vector{Float64} = data["x"]
    _y::Vector{Float64} = data["y"]
    _z::Vector{Float64} = data["z"]
    _vx::Vector{Float64} = data["vx"]
    _vy::Vector{Float64} = data["vy"]
    _vz::Vector{Float64} = data["vz"]
    _m::Vector{Float64} = data["m"]

    r = sqrt.((_x .- cmx).^2 .+ (_y .- cmy).^2 .+ (_z .- cmz).^2)

    _x = _x[r .< cutoff_radius]
    _y = _y[r .< cutoff_radius]
    _z = _z[r .< cutoff_radius]
    _vx = _vx[r .< cutoff_radius]
    _vy = _vy[r .< cutoff_radius]
    _vz = _vz[r .< cutoff_radius]
    _m = _m[r .< cutoff_radius]

    x=vcat(x, _x)
    y=vcat(y, _y)
    z=vcat(z, _z)
    vx=vcat(vx, _vx)
    vy=vcat(vy, _vy)
    vz=vcat(vz, _vz)
    m=vcat(m, _m)
end

npzwrite("CMVonly2.npz", Dict("x" => x, "y" => y, "z" => z, "vx" => vx, "vy" => vy, "vz" => vz, "m" => m))

println("Number of particles: ", length(x))
println("DONE!")