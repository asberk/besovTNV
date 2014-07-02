function Cthresh = besovROF( C, lambda )
%BESOVROF thresholds a vector of wavelet coefficients by a particular value
%   The function uses the thresholding value lambda to control the allowed
%   wavelet coefficients in C. The allowed ones are modified according to
%   the recharacterization of the Rudin-Osher-Fatemi model for image
%   denoising. 
%   The functional being minimized is 
%      F_f(u; \lambda) = \|u\|_{B^1_1(L^1)} + \lambda/2\|f- u\|_{L^2}^2,
%   which is equivalent to minimizing the function 
%             h_t(s; \lambda) = |s| + \lambda/2|t-s|^2,
%   for each (j,k,\psi)-wavelet coefficient, s, of u, where t is the
%   corresponding (j,k,\psi)-wavelet coefficient of f. 
%   Note: increasing lambda increases the amount of detail in the image
%   (equivalently, sets fewer coefficients to zero). 

Cthresh = zeros(size(C));
Cthresh(C>1./lambda) = C(C>1./lambda) - 1./lambda;
Cthresh(C<-1./lambda) = C(C<-1./lambda) + 1./lambda;

end

