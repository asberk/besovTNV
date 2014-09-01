% % TNVsandbox2.m - created to generate figures for research-notes.tex, etc., to exemplify norm convergence properties of the TNV-type decomposition over Besov(1,1,L^1). 
% This script is independent of TNVGUI. 
% This script depends on the file(s):
% * besovROF.m

%% Clear workspace
clear all; close all; clc;

%% Read image
A = imread('./../GraphSgmtn/img/cows.jpg');
A = double(rgb2gray(A))./255;

% set parameters and compute initial data
lambda = 0.029;
wname = 'db1';
wMaxLev = wmaxlev(size(A), wname); 
[wCoeff S] = wavedec2(A, wMaxLev, wname);
N = 14;

% Define custom color map
myMap = distinguishable_colors(N+1);
set(0, 'DefaultAxesColorOrder', myMap);

coeffV = wCoeff;
uCoeffMat = zeros(N+1, length(wCoeff));

%% Compute wavelet coefficients for u_n
uCoeffMat(1,:) = besovROF(coeffV, lambda);

for j = 1:N % image number (not index number)
    lambda = 2*lambda;
    coeffV = coeffV - uCoeffMat(j,:); % v_{j-1} % same as doing image reconstruction, subtraction and re-decomposition (thank you, orthogonality)
    uCoeffMat(j+1,:) = besovROF(coeffV, lambda); % u_{j}
end

uCSMat = cumsum(uCoeffMat);
vCoeffMat = bsxfun(@minus, wCoeff, uCSMat);

%% Plot u_n for n = 0, ..., N
h = figure(1);
subplot(1,1,1);
semilogx(log(1 + abs(uCoeffMat.')).*sign(uCoeffMat.'));
legend(cellfun(@num2str, num2cell(1:N), 'UniformOutput', 0));
title(['Semilog plot of $u_n$ for $n \leq ', num2str(N), '$'], 'Interpreter', 'latex', 'FontSize', 18);
ylabel('$u_{n,\ell}^*$', 'Interpreter', 'latex', 'FontSize', 16);
set(h, 'Color', [1 1 1]);

%% Plot Unsorted wavelet coefficients for cumsum(u) and v_n, n ? N
subplot(2, 1, 1);
semilogx(log(1 + abs(uCSMat(end:-1:1, :)).'));
legend(cellfun(@num2str, num2cell(N:-1:0), 'UniformOutput', 0), 'Location', 'East', 'FontSize', 12);

subplot(2, 1, 2);
semilogx(log(1 + abs(vCoeffMat.')));
legend(cellfun(@num2str, num2cell(0:N), 'UniformOutput', 0), 'Location', 'East', 'FontSize', 12);

%% Semilog plots for log-transformed decreasing rearrangements of wavelet coefficients for u, cumsum u and v 
% corresponds with fig:20140526-dec-rearr-cows-db1 in research-notes.tex
subplot(3,1,1);
semilogx(sort(log(1 + abs(uCoeffMat)), 2, 'descend').');
title('Semilog plot of decreasing rearrangement of log-transformed wavelet coefficients of $u_m$', 'Interpreter', 'latex', 'FontSize', 18);
ylabel('$\log \,\,(u_{m, \ell}^*\,\,)$', 'Interpreter', 'latex', 'FontSize', 16);

subplot(3, 1, 2);
semilogx(sort(log(1 + abs(uCSMat)), 2, 'descend').');
title('Semilog plot of decreasing rearrangement of log-transformed wavelet coefficients of $\sum_{n=0}^m u_n$', 'Interpreter', 'latex', 'FontSize', 18);
ylabel('$\log \,\,(\sum_{n=0}^m u_{n, \ell}^*\,\,)$', 'Interpreter', 'latex', 'FontSize', 16);
legend(cellfun(@num2str, num2cell(0:N), 'UniformOutput', 0), 'Location', 'EastOutside', 'FontSize', 12);


subplot(3, 1, 3);
semilogx(sort(log(1 + abs(vCoeffMat)), 2, 'descend').')
title('Semilog plot of decreasing rearrangement of log-transformed wavelet coefficients of $v_m$', 'Interpreter', 'latex', 'FontSize', 18);
ylabel('$\log \,\,(v_{m, \ell}^*\,\,)$', 'Interpreter', 'latex', 'FontSize', 16);

%set(gcf, 'Color', [1 1 1]);


%% Comparing L2 Norms to Besov Norms
uBesovNorms = sum(abs(uCoeffMat.'));
uL2Norms = sqrt(sum(uCoeffMat.'.^2));

uCSBesovNorms = sum(abs(uCSMat.'));
uCSL2Norms = sqrt(sum(uCSMat.'.^2));

vBesovNorms = max(vCoeffMat, [], 2).'; % get max of each column: B^{-1}_\infty(L^\infty) norm
vL2Norms = sqrt(sum(vCoeffMat.'.^2));

fL2Norm = sqrt(sum(wCoeff.^2));

% figure(1);
% subplot(2,1,1);
% plot([uL2Norms; uCSL2Norms; vL2Norms].', '.-');
% subplot(2,1,2);
% plot([uBesovNorms; uCSBesovNorms].', '.-');

%mC = mean(uCSL2Norms./uCSBesovNorms);

[yyax, yyh1, yyh2] = plotyy(0:N, [uL2Norms; uCSL2Norms; vL2Norms].', 0:N, [uBesovNorms; uCSBesovNorms; vBesovNorms].');
set(yyh1, 'Marker', '.');
set(yyh2, 'Marker', '.');
L = legend('$\|u_j\|_{L^2}$', '$\|\sum_{k=0}^j \,\,u_j\|_{L^2}$', '$\|v_j\|_{L^2}$', '$\|u_j\|_{B_1^1(L^1)}$', '$\|\sum_{k=0}^j \,\,u_j\|_{B^1_1(L^1)}$', '$\|v_j\|_{B^{-1}_\infty(L^\infty)}$');
set(L, 'Interpreter', 'latex', 'FontSize', 14, 'Location', 'East');
ylabel(yyax(1), '$L^2$', 'Interpreter', 'latex', 'FontSize', 16);
ylabel(yyax(2), '$B_1^1(L^1)$', 'Interpreter', 'latex', 'FontSize', 16);
xlabel(yyax(2), '$j$', 'Interpreter', 'latex', 'FontSize', 16);
hold on;
p = [0.7, 0, .9]; % purple
plot(yyax(1), [0 N], [fL2Norm, fL2Norm], '--');
hold off;
firstAxisChildren = get(yyax(1), 'Children');
set(firstAxisChildren(1), 'Color', p, 'LineWidth', 1);
set(gcf, 'Color', [1 1 1]);

%% More norm comparisons.

% Determine inner product of u and v at each lambda
ipUV = diag(uCoeffMat*vCoeffMat.');
display(ipUV);
ipUpperBound = (uBesovNorms.*vBesovNorms).';
display(ipUpperBound);
semilogy(0:N, ipUV, '-b');
hold on;
semilogy(0:N, ipUpperBound, '.r');
hold off;
xlabel('$j$', 'Interpreter', 'latex', 'FontSize', 16);
L = legend('$\int u_{j} v_{j} \,\mathrm{d} x$', '$\|u_j\|_{B^1_1(L^1)} \,\, \|v_j\|_{B^{-1}_\infty(L^\infty)}$');
set(L, 'Interpreter', 'latex', 'FontSize', 16);
set(gcf, 'Color', [1 1 1]);

%% Bounding L2 norm of v_m

plot(sort(log(1 + abs(vCoeffMat)), 2, 'descend').');

asdf = bsxfun(@gt, sort(abs(vCoeffMat), 2, 'descend'), 1./lambda./2.^([0:N].'));






