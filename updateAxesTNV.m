function updateAxesTNV(handles)

handles.axesTNVImage = imageTNV(handles); % returns sum of decomposed images
axes(handles.axesTNV); % set focus
cla; % clear figure
imshow(handles.axesTNVImage);
