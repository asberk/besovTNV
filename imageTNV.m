function A = imageTNV(handles)
%% IMAGETNV computes a Besov TNV decomposition for specified parameter values.
%    Given the parameters specified in handles, imageTNV sums the
%    wavelet coefficients of u_m through u_n where m is given by 
%    sliderLow.Value and n is given by sliderHigh.Value. The result is 
%    returned as a matrix (to be displayed by TNVGUI). 

m = get(handles.sliderLow, 'Value');
n = get(handles.sliderHigh, 'Value');

newCoeffs = sum(handles.coeffMat((m:n)+1,:), 1);

if get(handles.cbSubtract, 'Value')
    newCoeffs = sum(handles.coeffMat, 1) - newCoeffs;
% else 
%   everything remains as it is
end

A = waverec2(newCoeffs, handles.bookkeeping, handles.wname);

if get(handles.cbNormz, 'Value')
    A = A./max(A(:));
end
