function updateAxesNorms(handles)

% make bottom two plots of wavelet coefficients
Norm2f = sqrt(sum(handles.wCoeff.^2));
uL2Norms = sqrt(sum(handles.coeffMat.'.^2));
uCumsums = cumsum(handles.coeffMat);
uCSL2Norms = sqrt(sum(uCumsums.'.^2));
uBesovNorms = sum(abs(handles.coeffMat).');
uCSBesovNorms = sum(abs(uCumsums.'));
%mC = mean(uCSL2Norms./uCSBesovNorms);
vL2Norms = bsxfun(@minus, handles.wCoeff, uCumsums).';
vL2Norms = sqrt(sum(vL2Norms.^2));
%clear uCumsums;
%display(handles.sliderMax);

axes(handles.axesNorms);
cla reset;
hold on;
[yyax, yyh1, yyh2] = plotyy(1:handles.sliderMax+1, [uL2Norms; uCSL2Norms; vL2Norms].', 1:handles.sliderMax+1, [uBesovNorms; uCSBesovNorms].');
set(yyh1, 'Marker', '.');
set(yyh2, 'Marker', '.');
ylabel(yyax(1), '$L^2$', 'Interpreter', 'latex', 'FontSize', 16);
ylabel(yyax(2), '$B^1_1(L^1)$', 'Interpreter', 'latex', 'FontSize', 16);
L = legend('$\|u_j\|_{L^2}$', '$\|\sum_{k=0}^j \,\,u_j\|_{L^2}$', '$\|v_j\|_{L^2}$', '$\|u_j\|_{B_1^1(L^1)}$', '$\|\sum_{k=0}^j \,\,u_j\|_{B^1_1(L^1)}$');
set(L, 'Interpreter', 'latex', 'FontSize', 14, 'Location', 'East', 'Box', 'off');
plot([0, length(vL2Norms)], [Norm2f, Norm2f], '--m');
hold off;
hold off;
