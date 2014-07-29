function varargout = getWvltSM(C, S, level) 
%% GETWVLTSM(C,S,level) returns the wavelet submatrix of wavelet coefficients for a 2D image.
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

if (ischar(level) && strcmp(level, 'detail')) || uint16(level) == N+1
    varargout{1} = reshape(C(1:(S(1, 1)*S(1,2))), S(1,:)); % return detail coefficients

elseif isnumeric(level) && level <= N % check if level is a double
    level = uint16(N-level+1);
    before = S(1,1)*S(1,2) + sum(3*prod(S(2:level, :), 2));
    coeffRef = prod(S(level+1,:));
    %display(coeffRef);
    if nargout == 1
        varargout{1} = reshape(sum([...
            C(before + (1:coeffRef)); ...
            C(before + coeffRef + (1:coeffRef)); ...
            C(before + 2*coeffRef + (1:coeffRef))]), ...
            S(level+1, :));
    elseif nargout == 3
        for k = 1:3 % 1 = H, 2 = V, 3 = D
            varargout{k} = reshape(C(before + (k-1)*coeffRef + (1: coeffRef)), S(level+1,:));
        end
    else
        error('nargout must be equal 1 or 3.');
    end
else
    error('LEVEL must be a positive integer less than N, or ''detail'', where N = size(S, 1)');
end
