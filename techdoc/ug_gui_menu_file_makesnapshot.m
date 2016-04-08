%% Make a snapshot to a file or to clipboard.
% This dialog provides access to different settings for making snapshots. 
%
% *Back to* <im_browser_product_page.html *Index*> |*-->*| <im_browser_user_guide.html *User Guide*> 
% |*-->*| <ug_gui_menu.html *Menu*> |*-->*| <ug_gui_menu_file.html *File Menu*>
% 
% <<images\menuFileSnapshot.jpg>>
% 
%% Target
% Defines where to send the resulting image. The image may be saved to a file when the |File| option is selected, or copied
% to the clipboard, when the |Clipboard| options is selected.
%
%% Crop
%
% * *Full image* - make snapshot of the whole image.
% * *Shown area* - make snapshot of the shown in the <ug_panel_im_view.html Image View panel> area only.
% * *ROI* - use selected ROI (the ROI may be defined using <ug_panel_roi.html the ROI panel> ) as area for the snapshot.
%
%% Resize
% * *Width* - modifies width of the snapshot.
% * *Height* - modifies height of the snapshot.
% * *Resizing method* - select one of possible resizing methods.
%%
% <html>
% <ul>
% <li><em>nearest</em> - Nearest-neighbor interpolation; the output pixel is assignedthe value of the pixel that the point falls within. No other pixels are considered.
% <li><em>bilinear</em> - Bilinear interpolation; the output pixel value is a weighted average of pixels in the nearest 2-by-2 neighborhood.
% <li><em>bicubic</em> - Bicubic interpolation; the output pixelvalue is a weighted average of pixels in the nearest 4-by-4 neighborhood.
% </ul>
% </html>
% 
% * *Bin2* update the dimensions of the image after decreasing the image
% size in 2 times
% * *Bin4* update the dimensions of the image after decreasing the image
% size in 4 times
% * *Bin8* update the dimensions of the image after decreasing the image
% size in 8 times
% 
%% Options
%
% * *Scale bar* - select the |Scale bar| check box to add a scale bar to the snapshot. *Note!* if the width of the snapshot is too small the
% scale bar is not generated
% * *Measurements* - add the displayed measurements to the snapshot.
% Warning! The resulting image may have border artifacts, at least in
% Matlab R2014b. The snapshot is done using the _export_fig_ function
% written by <http://www.mathworks.com/matlabcentral/fileexchange/23629-export-fig Oliver Woodford and Yair Altman>
% * *Options* - define visualization options for the measurements
%
%% Format
% Select one of the possible formats. There are number of format specific settings available for each image format.
%%
% 
% * *BMP* - Windows Bitmap (BMP); 1-bit, 8-bit, and 24-bit uncompressed images.
% * *JPG* - Joint Photographic Experts Group (JPEG), 8-bit, 12-bit, and 16-bit Baseline JPEG images.  
% * *TIF* - Baseline Tagged Image File Format images, including 1-bit, 8-bit, 16-bit, and 24-bit uncompressed images.
% 
%
%
% *Back to* <im_browser_product_page.html *Index*> |*-->*| <im_browser_user_guide.html *User Guide*> 
% |*-->*| <ug_gui_menu.html *Menu*> |*-->*| <ug_gui_menu_file.html *File Menu*>