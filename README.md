# CREATE Module: Modelling instability of a submesoscale front using Oceananigans

## Hana's work

### General approach
I worked through the notes and Julia scripts in order. Derivations were written by hand and scanned. I used nvim to edit the scripts in Julia and ran the scripts in the terminal (for my memory, the command was `julia myscript.jl`).

### 3-simulation comments
For topic 3-simulation, I set the tracer initial condition to 
`c₀(x, z) = z`

I assumed that `M² = f * S` from the bottom of slide deck 2:
```math
q = fN^2\left (1 - \frac{M^4}{N^2f^2}\right ) = fN^2\left (1 - \frac{S^2}{N^2}\right ) \\
\implies \frac{M^4}{N^2f^2} = \frac{S^2}{N^2} \\
M^4 = f^2 S^2 \\
M^2 = fS
```

### 4-visualization comments
The single timestamp figure was saved to */src/exercise4.1.png*.

For topic 4-visualization, I made a separate version of `visualization.jl` for the animation, called `visualization-mp4.jl`. The output animation was named */videos/Ri05-exercise_4-2.mp4*. The animation showed that the state is fairly steady until about t=130hr, with linear, parallel buoyancy contours and a uniform passive tracer gradient with respect to depth. At that point, the instability growth becomes visible.

### 5-analysis comments
Simulation data for $Ri=[0.3, 0.5, 0.7, 0.9]$ were processed using `analysis.jl` to add kinetic energy and total Brunt-Vaisalla frequency fields. These derived fields were plotted using `post-processing.jl`. KE grows the most quickly with time for small $Ri$. Growth rate peaks the highest and earliest for small $Ri$, while growth rate is more sustained for larger $Ri$. All balanced $Ri$ exhibit oscillations over time, with oscillations being the most pronounced in the case of small $Ri$. 

## About the module
This is a module designed for the NSERC CREATE grant _Training for novel directions in quantitative climate science_. 

Begin by reading `notes/0-introduction.md` for an explanation and outline of the content of the module. Partially completed simulation, plotting and analysis scripts are in `src`. Exercises throughout the module instruct you to fill these out. Completed scripts are available in `src-complete` in case the coding exercises make no sense at all, and to check your own solutions.

Originally created in March 2026 by Erin Atkinson and [Nicolas Grisouard](https://sites.physics.utoronto.ca/nicolasgrisouard/group)

This is a working document, and future students are encouraged to update it as the software develops.
