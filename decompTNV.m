function coeffMat = decompTNV(handles) 
%% DECOMPTNV computes the TNV-type decomposition of a vector of wavelet coefficients.
%    Parameters of the decomposition are given by sliderLamInit.Value and
%    handles.sliderMax. Note that the initial wavelet decomposition has
%    already been performed, with the result stored in handles. 
%    This function returns a matrix whose rows represent u_0, u_1, ... of
%    the TNV-type decomposition, where f = u0 + v0 = u0 + u1 + v1 = ...

lambda = exp(get(handles.sliderLamInit, 'Value')); % initial threshold value

% m = get(handles.sliderLow, 'Value'); % lower
% n = get(handles.sliderHigh, 'Value'); % higher
N = handles.sliderMax;

coeffV = handles.wCoeff; % set f = "v_{-1}" 
coeffMat = zeros(N+1, length(handles.wCoeff));
coeffMat(1,:) = besovROF(coeffV, lambda); % u_0

for j = 1:N % image number (not index number)
    lambda = 2*lambda;
    coeffV = coeffV - coeffMat(j,:); % v_{j-1} % same as doing image reconstruction, subtraction and re-decomposition (thank you, orthogonality)
    coeffMat(j+1,:) = besovROF(coeffV, lambda); % u_{j}
end

end