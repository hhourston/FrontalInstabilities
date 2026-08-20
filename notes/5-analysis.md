# Analysis
This section introduces use of `ARGS` to allow Julia scripts to access command-line arguments, and describes post-processing using Oceananigans. The output from multiple simulations is used to show the dependence of instability growth rate on the initial Richardson number.

## Domain averages

Define the domain average $`\langle \cdot \rangle`$ as
```math
\langle c\rangle(t) = \frac{1}{LH}\iint c(x, z, t)\,\text{d}x\text{d}z.
```

Recall the form of a plane wave from section 2:

```math
u =  \Re \left (\tilde ue^{ikx + imz - i\omega t}\right ).
```

For instability, $`\omega = \pm i\sigma`$ where $`\sigma`$ is the growth rate of the instability. It follows that the average kinetic energy density of the unstable mode is

```math
\text{KE} = \frac{1}{2}\left (\Re(\tilde u)^2 + \Re(\tilde v)^2 + \Re(\tilde w)^2\right )e^{2\sigma t} \langle g\rangle ,
```

where $`g(x, z)`$ is some sinusoidal function that describes the shape of the mode. We can then estimate the growth rate, assuming that the most unstable mode dominates, using

```math
\ln \text{KE} = A + 2\sigma t.
```

We will investigate how the growth rate of the instability depends on the initial Richardson number, and how the Richardson number changes over time

> ### Exercise 1
> Show that the balanced Richardson number, defined by
> 
> $$\text{Ri}_b(t) = f^2\frac{\left \langle \frac{\partial b_\text{tot}}{\partial z}\right\rangle}{ \left\langle \frac{\partial b_\text{tot}}{\partial x}\right\rangle^2}.$$
> 
> May be written, for the boundary conditions in our simulation, as
> 
> $$\text{Ri}_b(t) = \frac{\langle N^2_\text{tot}(t)\rangle}{S^2}$$
> 

## Parameter sweep

It would be impractical to edit `simulation.jl` each time we want to change some parameters. We can make use of the `ARGS` variable to run multiple versions of the same simulation. `ARGS` is a Julia environment variable that contains a vector of the command-line arguments the script was run with (not the arguments for `julia` itself, such as the number of threads or project path). For instance, the simple program

```julia
# args-example.jl
for arg in ARGS
    println(arg)
end
```

when run from the terminal will print the entered arguments:

```bash
$ julia args-example.jl one two three
one
two
three
```
Note that all the entries are strings, so if we are expecting a different type we must use `parse`:
```julia
# args-arithmetic.jl
a = parse(Float64, ARGS[1])
b = parse(Float64, ARGS[2])
println(a + b)
```

```bash
$ julia args-arithmetic.jl 1e3 12.76
1012.76
```

We can clearly separate arguments for `julia` from arguments for the script using a double-dash `--`:

```bash
$ julia -t 3 -- args-arithmetic.jl -0.5 8e-2
-0.42
```

> ### Exercise 2
>
> Modify the simulation code to instead read an initial $\text{Ri}$ value and output filename from the command-line arguments using `ARGS`, then run simulations for $\text{Ri} = \{0.3, 0.7, 0.9\}$ in addition to the existing $\text{Ri}=0.5$ output.
> Smaller $\text{Ri}$ will take longer (why?). Using the same resolution, the $\text{Ri} = 0.3$ simulation took 20 minutes.

## Post-processing
Once we have simulations for varying $\text{Ri}$, we can compare our results, however, first we will want to do some post-processing using Oceananigans. As well as simulations, Oceananigans provides powerful post-processing capabilities using `Field`s paired with `AbstractOperation`s. These work much the same way as when they are used for simulation output, but with a bit of boiler-plate code for reading and writing. Documentation is available at [Operations ⋅ Oceananigans.jl](https://clima.github.io/OceananigansDocumentation/v0.102.5/operations/#Operations-and-averaging)

## Simple post-processing workflow

Here is an example script that produces total kinetic energy and kinetic energy density:

```julia
using Oceananigans

input = "Ri03.jld2"
output = "Ri03-KE.jld2"

# Read in the raw output
fds = FieldDataset(input; backend=OnDisk())

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

# Kinetic energy density
η = Field((u^2 + v^2 + w^2) / 2)

# Average kinetic energy of the instability
KE = Field(Average(η))

outputs = (; η, KE)

# Creating empty OnDisk FieldDataset allows output
output_fds = FieldDataset(times, outputs;
    backend = OnDisk(),
    path = output,
)

# Iterate over times
N = length(u_fts)
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
```

Much of the code can be reused with just different entries in `outputs`. 

> ### Exercise 3
> Add an operation to `src/analysis.jl` to produce the balanced Richardson number `Rib` as defined in exercise 2. Run with the input `RiXX.jld2` as an argument to produce `RiXX-pp.jld2` for each simulation. The script should complete quickly.

Running `post-processed.jl` should produce the following figure of the average kinetic energy, growth rate and bulk Richardson number.

> ![Average kinetic energy and bulk Richardson number](../images/post-processed.png)
> Average kinetic energy, growth rate and bulk Richardson number over time for each of the simulations

The instability restores the flow to a stable state, with $`\text{Ri}_b > 1`$, and grows faster for larger initial Richardson number. In addition, the sudden impact of the instability, especially starting in very unstable states, kicks off oscillations, which show up in the bulk Richardson number. 
