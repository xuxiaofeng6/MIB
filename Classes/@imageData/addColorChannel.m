function handles = addColorChannel(obj, img, handles, channelId)
% function handles = addColorChannel(obj, img, handles, channelId)
% Add a new color channel to the existing dataset
%
% Parameters:
% img: new 2D/3D image stack to add
% handles: handles structure from im_browser
% channelId: @b [optional] number (single!) of the channel to add, if NaN a new color channel is created
%
% Return values:
% handles: handles structure from im_browser

%| 
% @b Example:
% @code handles = imageData.addColorChannel(img, handles, channelId);     // replace the color channel (channelId) with new img  @endcode
% @code handles = addColorChannel(obj, img); // Call within the class; add img as a new color channel @endcode

% Copyright (C) 30.10.2013, Ilya Belevich (ilya.belevich @ helsinki.fi)
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates:
% 18.09.2016, changed .slices to cells

                

if nargin < 4; channelId = NaN; end;

if size(obj.img,1) ~= size(img, 1) || size(obj.img,2) ~= size(img, 2) || size(obj.img,4) ~= size(img, 4)
    button = questdlg(sprintf('Warning!\nSome of the image dimensions mismatch.\nContinue anyway?'),'Dimensions mismatch!','Continue','Cancel','Continue');
    if strcmp(button,'Cancel'); handles = NaN; return; end;
end
wb = waitbar(0,'Please wait...','Name','Add color...','WindowStyle','modal');
zMax = min([size(obj.img,4) size(img,4)]);
xMax = min([size(obj.img,2) size(img,2)]);
yMax = min([size(obj.img,1) size(img,1)]);
if isnan(channelId)     % add img as a new channel
    noExistingColors = size(obj.img,3);
    noExtraColors = size(img,3);
    waitbar(0.1, wb);
    obj.img(1:yMax,1:xMax,noExistingColors+1:noExistingColors+noExtraColors,1:zMax) = img(1:yMax,1:xMax,:,1:zMax);
    waitbar(0.9, wb);
    obj.colors = noExistingColors+noExtraColors;
    obj.img_info('ColorType') = 'truecolor';
    obj.viewPort.min(noExistingColors+1:noExistingColors+noExtraColors) = 0;
    obj.viewPort.max(noExistingColors+1:noExistingColors+noExtraColors) = double(intmax(class(img)));
    obj.viewPort.gamma(noExistingColors+1:noExistingColors+noExtraColors) = 1;
    obj.slices{3} = [obj.slices{3} numel(obj.slices{3})+1];
else
    waitbar(0.1, wb);
    obj.img(1:yMax,1:xMax,channelId,1:zMax) = img(1:yMax,1:xMax,1,1:zMax);
    waitbar(0.9, wb);
    obj.viewPort.min(channelId) = 0;
    obj.viewPort.max(channelId) = double(intmax(class(img)));
    obj.viewPort.gamma(channelId) = 1;
end
waitbar(1, wb);
delete(wb);
end