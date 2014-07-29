#README
-----
This project has three main files:
* `TNVGUI.m` and `TNVGUI.fig`
* `TNVsandbox1.m`
* `TNVsandbox2.m`

* The first file, as its name suggests is a GUI that can be run,
edited using the Matlab interface, `guide`. This GUI allows the
user to load in an image, specify a type of wavelet and, after
specifying the necessary parameters, allow the user to visualize a
decomposition that is similar to the one first described by
Tadmor, Nezzar and Vese; however, the decomposition is performed
over the Besov space B_1^1(L^1).
* The second file is used to generate sample images to exemplify
efficacy of the denoising process, as described by
Rudin-Osher-Fatemi, but again over the Besov space
B_1^1(L^1). `TNVsandbox1.m` also generates sample images for an
example TNV-type decomposition. 
* The third file generates plots for norm-convergence properties
of the TNV-type decomposition over the Besov space
B_1^1(L^1). Plots of the wavelet-coefficients are generated, in
addition to plots of the B_1^1(L^1), L^2, and
B_{-1}_\infty(L^\infty) norms for various components of the
decomposition(s). 

The remainder of the files in this project are "helper" files that
either aid in the function of the GUI [all `update*.m` files,
`distinguishable_colors.m`, getImage.m], or the computation of the
image decompositions [`besovROF.m`], or both [`decompTNV.m`,
`imageTNV.m`].

Note that `getWvltSM.m` is really a debugging-type function, which
is not used by any of the other files in the project. See its help
file for further detail. 