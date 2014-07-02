function newHandles = updateSlidersLH(handles)
%% updates sliderLow and sliderHigh, as well as the associated edit fields.
sliderLamInit_Value = exp(get(handles.sliderLamInit, 'Value'));

% define sliderMax
if sliderLamInit_Value == 0 % should no longer happen
    handles.sliderMax = 1;
else
    handles.sliderMax = floor(log2(1+ handles.wMaxAbs/sliderLamInit_Value));
end

% fix if sliderMax is wonky
if handles.sliderMax < 0
    handles.sliderMax = 0;
end

% set SliderSteps
if handles.sliderMax == 0
    handles.sliderStepLow = [1,1];
    handles.sliderStepHigh = [1,1];
else
    % sliderStepLow
    handles.sliderStepLow = [1,1]./(handles.sliderMax); %step/(max - min)
    %sliderStepHigh
    divVal = handles.sliderMax - get(handles.sliderLow, 'Value');
    if divVal == 0
        handles.sliderStepHigh = [1,1]; % because, from above, max = 1, min = 0
    else
        handles.sliderStepHigh = [1,1]./divVal;
    end
end

set(handles.sliderLow, 'Min', 0, 'Max', handles.sliderMax, 'SliderStep', handles.sliderStepLow);
if get(handles.sliderLow, 'Value') > handles.sliderMax
    set(handles.sliderLow, 'Value', handles.sliderMax);
else
    set(handles.sliderLow, 'Value', get(handles.sliderLow, 'Value'));
end

set(handles.sliderHigh, 'Min', get(handles.sliderLow, 'Value'), 'Max', ...
    handles.sliderMax, 'SliderStep', handles.sliderStepHigh);
if get(handles.sliderHigh, 'Value') > handles.sliderMax
    set(handles.sliderHigh, 'Value', handles.sliderMax);
else
    set(handles.sliderHigh, 'Value', ...
        max(get(handles.sliderHigh, 'Min'), get(handles.sliderHigh, 'Value')));
end

%set(handles.editLamInit, 'String', num2str(round(1000*get(handles.sliderLamInit, 'Value'))/1000));
set(handles.editLow, 'String', num2str(get(handles.sliderLow, 'Value')));
set(handles.editHigh, 'String', num2str(get(handles.sliderHigh, 'Value')));


newHandles = handles;

end