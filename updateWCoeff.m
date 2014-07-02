function newHandles = updateWCoeff(handles)
handles.wMaxLev = wmaxlev(handles.imageSize, handles.wname);
[handles.wCoeff, handles.bookkeeping] = wavedec2(handles.currentImage, handles.wMaxLev, handles.wname);
handles.wMaxAbs = max(abs(handles.wCoeff));

newHandles = handles;