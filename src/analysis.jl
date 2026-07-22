using Oceananigans

input = ARGS[1]
output = replace(ARGS[1], ".jld2" => "-pp.jld2")

# Read in the raw output
fds = FieldDataset(input; backend=OnDisk())
p = fds.metadata["parameters"]

# Create input fields
u = fds.u[1]
v = fds.v[1]
w = fds.w[1]
b = fds.b[1]
c = fds.c[1]
N²_tot = fds.N²_tot[1]

# Times and grid
grid = fds.u.grid
times = fds.u.times

# Average kinetic energy of the instability
KE = Field(Average((u^2 + v^2 + w^2) / 2))

# Balanced Richardson number
Rib = Field(Average(N²_tot / p.S^2))

outputs = (; KE, Rib)

output_fds = FieldDataset(times, outputs; 
    backend = OnDisk(), 
    path = output,
    metadata = fds.metadata
)

# Iterate over times
N = length(times)
for n in 1:N
    # Update input fields to this time
    set!(u, fds.u[n])
    set!(v, fds.v[n])
    set!(w, fds.w[n])
    set!(b, fds.b[n])
    set!(c, fds.c[n])
    set!(N²_tot, fds.N²_tot[n])

    # Compute fields (this automatically computes dependencies)
    compute!(outputs)

    # Save the result to disk
    set!(output_fds, n; outputs...)

    print("$n / $N\r")
end
