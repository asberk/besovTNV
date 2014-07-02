function updateAxesWvlt(handles) 

m = get(handles.sliderLow,'Value');
n = get(handles.sliderHigh, 'Value');

axes(handles.axesWvlt);
cla;
plot((sign(handles.coeffMat((m:n)+1,:)).*log(1+abs(handles.coeffMat((m:n)+1,:)))).');
ff = @(x) num2str(x);
legendLabels = cellfun(ff, num2cell(m:n), 'UniformOutput', 0);
legend(legendLabels);
