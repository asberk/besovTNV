% % TNVsandbox1.m - created to generate figures for the Medical Imaging paper, to exemplify ROF-type denoising properties over Besov(1,1,L^1), and to give an example of TNV-type decomposition over Besov(1,1,L^1).
% This script is independent of TNVGUI.
% This script depends on the file(s):
% * besovROF.m

%% Clear workspace
clear all; close all; clc;

%% Set parameter values; load image
% the reformatting in this section was done to verify
% compatibility. It turns out that the original uint8 format of X isn't
% conducive. 

% barbara image located at ./img/barbara.png
% house image located at ./img/textures/1.4.05.tiff
X = imread('../GraphSgmtn/img/textures/1.4.05.tiff');
namestr = 'house.tiff';
Xgray = double(X)/255; % convert to (0,1) scale.

% wavelet type
wname = 'db10';

% parameters of noise
noiseType = 0;
noisePct = .25;


%% Create working data
switch noiseType
    case 0
        eta = zeros(size(Xgray));
        noiseVar = '';
    case 1
        % uniform noise
        eta = 2*noisePct*rand(size(Xgray))-noisePct;
        noiseVar = '+ \eta_1';
    case 2
        % transformed-normal noise
        etaN = randn(size(Xgray)); % values still in (-inf, inf)
        eta = noisePct*(etaN./sqrt(1 + etaN.^2));
        noiseVar = '+ \eta_2';
    otherwise 
        error('noiseType must be in {0, 1, 2}');
end

Xgray = Xgray + eta;

%% Compute wavelet decomposition
[C, S] = wavedec2(Xgray, 5, wname); % wavelet decomposition using Haar

% each row of S gives the dimensions of the matrix at the corresponding
% "level". The first set is the approximation coefficients, then Horiz
% detail, then vert detail, then diag detail, then horiz, vert and diag at
% the next level up, etc., etc. 

%% Thresholding for ROF-type denoising
mult = [50, 60, 100];
Lmult = length(mult);
Cmat = zeros(Lmult+1, length(C));
Cmat(1,:) = C; % == f

figure; set(gcf, 'color', 'w');
subplot(1, Lmult+1, 1);
imshow(Xgray);
title(['$f ', noiseVar, '$'], 'Interpreter', 'latex', 'FontSize', 16);
for j = 1:Lmult
    lambda = mult(j)*mean(C);
    Cmat(j+1,:) = besovROF(Cmat(1,:), 1./lambda);
    subplot(1,Lmult+1, j+1);
    imshow(waverec2(Cmat(j+1,:), S, wname));
    title(['$1/\lambda = ', num2str(mult(j)), '\mathrm{mean}~(C)$'], 'Interpreter', 'latex', 'FontSize', 16);
end


%% Thresholding for TNV-type Multiscale Decomposition. 
% Fix lambda.
mult2 = 4;
lambda = mult2*mean(C); % make an arbitrary choice of lambda
                  % for now, lambda < 1, so we invert to make large
                  
nc = 2; nr = 3; % number column, rows, resp. (when plotting results)
Ndecomp = nc*nr-1; % number of decompositions to perform
Cmat = zeros(Ndecomp+1, length(C)); % store wavelet coefficients of u
Cmat(1, :) = C; % == f
Cmat(2,:) = besovROF(Cmat(1,:), 1./lambda);

v = Cmat(1,:);
for j = 2:Ndecomp
    lambda = 2*lambda;
    v = v - Cmat(j,:);
    Cmat(j+1,:) = besovROF(v, 1./lambda);
end

figure;
set(gcf, 'color','w');
for j = 1:(Ndecomp+1)
    subplot(nc,nr,j);
    imgj = waverec2(Cmat(j,:), S, wname);
    
    if (j>=3)
        imshow(imgj+.2);
    else
        imshow(imgj);
    end
    if (j == 1)
        title(['$f = u + v ', noiseVar, '$, ', namestr], 'Interpreter', 'latex', 'FontSize', 16);
    else
        title(['$u_', num2str(j-2),'$, $\lambda_', num2str(j-2),' = ', num2str(2^(j-2)*mult2), '\mathrm{mean}~(C)$'], 'Interpreter', 'latex', 'FontSize', 16);
    end
    
end

%% Visualize residual component
figure;
set(gcf, 'color', 'w');
vcmpt = waverec2(Cmat(1,:) - sum(Cmat(2:end,:)), S, 'haar');
imshow(vcmpt+.3);
title('Noise component, $v = f - (u_1 + u_2 + \ldots)$', ...
    'Interpreter', 'latex', 'FontSize', 16);
