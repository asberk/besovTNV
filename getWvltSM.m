function varargout = getWvltSM(C, S, level) 
%% GETWVLTSM returns the wavelet submatrix of wavelet coefficients for a 2D image.
%      Given the vector decomposition C and bookkeeping matrix S, getWvltSM returns 
%      a matrix whose elements contain the wavelet coefficients of a 2D image at 
%      scale LEVEL. This is achieved by indexing C with S and reshaping the
%      appropriate subvector of C to the appropriate shape S(LEVEL,:). Note
%      that horizontal, diagonal and vertical coefficents are summed and
%      returned as one matrix.
%
%      This functions is useful in debugging, or exploring certain levels 
%      of the wavelet coefficients indidividually.
%  

N = size(S, 1) - 2; % length of cascade / number of decompositions
level = uint16(level);

if strcmp(level, 'detail')
    varargout = C(1:(S(1, 1)*S(1,2))); % return detail coefficients
else % check if level is a double
    if isnumeric(level) && level <= N
        before = S(1,1)*S(1,2) + sum(3*prod(S(2:level, :), 2));
        coeffRef = prod(S(level+1,:));
        display(coeffRef);
        for k = 1:3 % 1 = H, 2 = V, 3 = D
            varargout{k} = reshape(C(before + (k-1)*coeffRef + (1: coeffRef)), [sqrt(coeffRef), sqrt(coeffRef)]);
        end
    else 
        error('you messed up');
    end
end
