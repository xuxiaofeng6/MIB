function ib_moveLayers(hObject, eventdata, handles, obj_type_from, obj_type_to, layers_id, action_type)
% function ib_moveLayers(hObject, eventdata, handles, obj_type_from, obj_type_to, layers_id, action_type)
% to move information between the layers.
%
% for example, to move selection to mask, or selection to material of the model
%
% Parameters:
% hObject: handle of a calling object
% eventdata: not used
% handles: handle structure of im_browser, not used because it is updated by the @em guidata function
% obj_type_from: name of a layer to get data, ''selection'', ''mask'', or ''model''
% obj_type_to: name of a layer to set data, ''selection'', ''mask'', or ''model''
% layers_id: a string
% - ''2D'' - 2D mode, move only the shown slice [y,x]
% - ''3D'' - 3D mode, move 3D dataset [y,x,z]
% - ''4D'' - 4D mode, move 4D dataset [y,x,z,t]
% action_type: a type of the desired action
% - ''add'' - add mask to selection
% - ''remove'' - remove mask from selection
% - ''replace'' - replace selection with mask
%
% Return values:

%| @b Examples:
% @code ib_moveLayers(handles.updatefilelistBtn, NaN, NaN, 'selection', 'mask', 'add');     // add selection to mask  @endcode
% @code ib_moveLayers(handles.updatefilelistBtn, NaN, NaN, 'selection', 'mask', 'remove');     // remove selection from mask  @endcode

% Copyright (C) 07.09.2013, Ilya Belevich, University of Helsinki (ilya.belevich @ helsinki.fi)
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% Updates
% 18.09.2016, IB, changed .slices to cells
% 20.01.2016, IB, replaced layers_id from current/all to 2D/3D; updated for 4D
% 22.08.2016, IB, fixed 3D case when the blockmode enabled from the YZ/XZ orientations
% 25.10.2016, IB, updated for segmentation table

handles = guidata(hObject);
t1 = tic;

% when the Selection layer is disabled and obj_type_from/to is selection ->
% return
if strcmp(handles.preferences.disableSelection, 'yes')
    warndlg(sprintf('The models, selection and mask layers are switched off!\n\nPlease make sure that the "Disable selection" option in the Preferences dialog (Menu->File->Preferences) is set to "no" and try again...'),'The models are disabled','modal');
    return; 
end;

userData = get(handles.segmTable, 'UserData');

contSelIndex = userData.prevMaterial - 2;    % index of the selected material
if strcmp(obj_type_from, 'model') && contSelIndex == - 1
    obj_type_from = 'mask'; 
end;
contAddIndex = userData.prevAddTo - 2;       % index of the target material

selected_sw = get(handles.segmSelectedOnlyCheck,'value');   % when 1- limit selection only for the selected material
maskedAreaSw = get(handles.maskedAreaCheck,'Value');    % when checked will do add, replace, remove actions only in the masked areas

% check for existance of the model layer
if handles.Img{handles.Id}.I.modelExist == 0 && strcmp(obj_type_to, 'model')
    msgbox(sprintf('Please Create the Model first!\n\nPress the Create button in the Model panel'),'The model is missing!','warn')
    return;
end

% tweak, when there is only a single slice in the dataset
if strcmp(layers_id,'4D') && handles.Img{handles.Id}.I.time==1
    layers_id = '3D';
end
% tweak, when there is only a single slice in the dataset
if strcmp(layers_id,'3D') && handles.Img{handles.Id}.I.no_stacks==1
    layers_id = '2D';
end

if strcmp(layers_id, '2D')
    switch3d = 0;
else
    switch3d = 1;
    wb = waitbar(0,[action_type ' ' obj_type_from ' to/with ' obj_type_to ' for ' layers_id ' layer(s)...'],'Name','Moving layers...','WindowStyle','modal');
end

if strcmp(layers_id, '4D')
    options.t = [1 handles.Img{handles.Id}.I.time];
elseif strcmp(layers_id, '3D')
    options.t = [handles.Img{handles.Id}.I.slices{5}(1) handles.Img{handles.Id}.I.slices{5}(1)];
else
    options = struct;
end

% do backup, not for 4D data
if ~strcmp(layers_id,'4D')
    if ~strcmp(handles.Img{handles.Id}.I.model_type, 'uint6')
        if handles.preferences.max3dUndoHistory > 2 || switch3d == 0
            ib_do_backup(handles, obj_type_from, switch3d);
        end;
    end
    ib_do_backup(handles, obj_type_to, switch3d);
end

% The first part is to speed up movement of layers for whole dataset, i.e. without ROI mode and without blockmode switch
if strcmp(layers_id,'4D') || (strcmp(layers_id,'3D') && handles.Img{handles.Id}.I.time==1) && strcmp(get(handles.toolbarShowROISwitch,'state'), 'off') && strcmp(get(handles.toolbarBlockModeSwitch,'state'), 'off')  % to be used only with full datasets, for roi mode and single slices check the procedures below
    options.contSelIndex = contSelIndex; % index of the selected material
    options.contAddIndex = contAddIndex; % index of the target material
    options.selected_sw = selected_sw;   % when 1- limit selection only for the selected material
    options.maskedAreaSw = maskedAreaSw;    % when checked will do add, replace, remove actions only in the masked areas
    
    switch obj_type_from
        case 'mask'
            switch obj_type_to
                case 'selection'
                    handles.Img{handles.Id}.I.moveMaskToSelectionDataset(action_type, options);     
                case 'model'
                    error('ib_moveLayers: mask->model is not implemented');
                case 'mask'
                    return;
            end
        case 'model'
            switch obj_type_to
                case 'selection'
                    handles.Img{handles.Id}.I.moveModelToSelectionDataset(action_type, options);    
                case 'mask'
                    handles.Img{handles.Id}.I.moveModelToMaskDataset(action_type, options);   
                case 'model'
                    return;
            end
        case 'selection'
            switch obj_type_to
                case 'mask'
                    handles.Img{handles.Id}.I.moveSelectionToMaskDataset(action_type, options);     
                case 'model'
                    handles.Img{handles.Id}.I.moveSelectionToModelDataset(action_type, options);
                case 'selection'
                    return;
            end
    end
else    % move layers for 2D/3D and ROI and block modes
    if handles.Img{handles.Id}.I.blockModeSwitch
        doNotTranspose = 0;
    else
        doNotTranspose = 4;
    end
    switch obj_type_from
        case 'mask'     % select mask layer
            if switch3d
                img = ib_getDataset('mask', handles, doNotTranspose, NaN, options);
            else
                img = ib_getSlice('mask', handles);
            end
        case 'model'      % select obj layer
            if handles.Img{handles.Id}.I.modelExist == 0 || strcmp(handles.Img{handles.Id}.I.model_type, 'int8'); delete(wb); return; end;     % different model type
            if switch3d
                img = ib_getDataset('model', handles, doNotTranspose, contSelIndex, options);
            else
                img = ib_getSlice('model', handles, NaN, NaN, contSelIndex);
            end
        case 'selection'
            if switch3d
                img = ib_getDataset('selection', handles, doNotTranspose, NaN, options);
                handles.Img{handles.Id}.I.clearSelection('3D');
            else
                img = ib_getSlice('selection', handles);
                handles.Img{handles.Id}.I.clearSelection('2D');
            end
    end
    
    % filter results
    if selected_sw && ~strcmp(obj_type_from,'model') && ~isnan(handles.Img{handles.Id}.I.model(1,1,1)) && ~strcmp(obj_type_to,'model')
        if switch3d
            sel_img = ib_getDataset('model', handles, doNotTranspose, contSelIndex, options);
        else
            sel_img = ib_getSlice('model', handles, NaN, NaN, contSelIndex);
        end
        for i=1:numel(img)
            img{i} = bitand(img{i}, sel_img{i});    % img{:}(sel_img{:}==0) = 0;
        end
        clear sel_img;
    end
    
    if maskedAreaSw
        if ~strcmp(obj_type_from,'mask') && ~strcmp(obj_type_to,'mask')
            if switch3d
                mask = ib_getDataset('mask', handles, doNotTranspose, NaN, options);
            else
                mask = ib_getSlice('mask', handles);
            end
            
            for i=1:numel(mask)
                img{i} = bitand(img{i}, mask{i});
            end
            clear mask;
        end
    end
    
    if switch3d     %3d mode full dataset
        switch obj_type_to
            case 'selection'
                switch action_type
                    case 'add'
                        selection = ib_getDataset('selection', handles, doNotTranspose, NaN, options);
                        for i=1:numel(img)
                            selection{i} = bitor(selection{i}, img{i}); %selection{:}(img{:}==1) = 1;
                        end
                    case 'replace'
                        selection = img;
                    case 'remove'
                        selection = ib_getDataset('selection', handles, doNotTranspose, NaN, options);
                        for i=1:numel(img)
                            selection{i} = selection{i}-img{i};  %selection{:}(img{:}==1) = 0;
                        end
                end
                ib_setDataset('selection', selection, handles, doNotTranspose, NaN, options);
            case 'mask'
                handles.Img{handles.Id}.I.maskExist = 1;
                if ~strcmp(handles.Img{handles.Id}.I.model_type, 'uint6')
                    if isnan(handles.Img{handles.Id}.I.maskImg(1));
                        handles.Img{handles.Id}.I.maskImg = zeros([handles.Img{handles.Id}.I.height,handles.Img{handles.Id}.I.width,handles.Img{handles.Id}.I.no_stacks,handles.Img{handles.Id}.I.time], 'uint8');
                    end;
                end
                switch action_type
                    case 'add'
                        mask = ib_getDataset('mask', handles, doNotTranspose, NaN, options);
                        for i=1:numel(mask)
                            mask{i} = bitor(mask{i}, img{i});   % mask{:}(img{:}==1) = 1;
                        end
                    case 'replace'
                        mask = img;
                    case 'remove'
                        mask = ib_getDataset('mask', handles, doNotTranspose, NaN, options);
                        for i=1:numel(img)
                            mask{i} = mask{i} - img{i}; % mask{:}(img{:}==1) = 0;
                        end
                end
                ib_setDataset('mask', mask, handles, doNotTranspose, NaN, options);
                set(handles.maskShowCheck,'Value',1);
            case 'model'
                if handles.Img{handles.Id}.I.modelExist == 0 || strcmp(handles.Img{handles.Id}.I.model_type, 'int8'); delete(wb); return; end;
                model = ib_getDataset('model', handles, doNotTranspose, NaN, options);     %model = ib_getDataset('model', handles, 4, contAddIndex); <- seems to be slower
                
                handles.Img{handles.Id}.I.modelExist = 1;
                switch action_type
                    case 'add'
                        for i=1:numel(img)
                            model{i}(img{i}==1) = contAddIndex;
                        end
                    case 'replace'
                        for i=1:numel(img)
                            model{i}(model{i}==contAddIndex) = 0;
                            model{i}(img{i}==1) = contAddIndex;
                        end
                    case 'remove'
                        if selected_sw
                            for i=1:numel(img)
                                model{i}(bitand(img{i}, model{i}/contSelIndex)==1) = 0; %model{:}(img{:}==1 & model{:} == contSelIndex) = 0;
                            end
                        else
                            for i=1:numel(img)
                                model{i}(img{i}==1) = 0;
                            end
                        end
                end
                ib_setDataset('model', model, handles, doNotTranspose, NaN, options);
        end
    else    % 2d mode, the current slice only
        switch obj_type_to
            case 'selection'
                switch action_type
                    case 'add'
                        selection = ib_getSlice('selection', handles);
                        for i=1:numel(img)
                            selection{i}(img{i}==1) = 1;
                        end
                    case 'replace'
                        selection = img;
                    case 'remove'
                        selection = ib_getSlice('selection', handles);
                        for i=1:numel(img)
                            selection{i}(img{i}==1) = 0;
                        end
                end
                ib_setSlice('selection', selection, handles);
            case 'mask'
                handles.Img{handles.Id}.I.maskExist = 1;
                if ~strcmp(handles.Img{handles.Id}.I.model_type, 'uint6')
                    if isnan(handles.Img{handles.Id}.I.maskImg(1)); handles.Img{handles.Id}.I.maskImg = zeros([handles.Img{handles.Id}.I.height,handles.Img{handles.Id}.I.width,handles.Img{handles.Id}.I.no_stacks,handles.Img{handles.Id}.I.time],'uint8'); end;
                end
                switch action_type
                    case 'add'
                        mask = ib_getSlice('mask', handles);
                        for i=1:numel(mask)
                            mask{i} = bitor(mask{i}, img{i});       % mask{:}(img{:}==1) = 1;
                        end
                    case 'replace'
                        mask = img;
                    case 'remove'
                        mask = ib_getSlice('mask', handles);
                        for i=1:numel(img)
                            mask{i} = mask{i} - img{i}; % mask{:}(img{:}==1) = 0;
                        end
                end
                ib_setSlice('mask', mask, handles);
                set(handles.maskShowCheck,'Value',1);
            case 'model'
                if handles.Img{handles.Id}.I.modelExist == 0 || strcmp(handles.Img{handles.Id}.I.model_type, 'int8');
                    msgbox(sprintf('No model, or the model of the wrong type.\n\nPress the Create button in the Segmentation panel to start a new model.'),'Problem with model','error');
                    return;
                end;
                handles.Img{handles.Id}.I.modelExist = 1;
                
                model = ib_getSlice('model', handles);     % model = ib_getSlice('model', handles, NaN, NaN, contAddIndex); <-this option seems to be slower
                switch action_type
                    case 'add'
                        for i=1:numel(img)
                            model{i}(img{i}==1) = contAddIndex;
                        end
                    case 'replace'
                        for i=1:numel(img)
                            model{i}(model{i}==contAddIndex) = 0;
                            model{i}(img{i}==1) = contAddIndex;
                        end
                    case 'remove'
                        if selected_sw
                            for i=1:numel(img)
                                model{i}(img{i}==1 & model{i} == contSelIndex) = 0;
                            end
                        else
                            for i=1:numel(img)
                                model{i}(img{i}==1) = 0;
                            end
                        end
                end
                ib_setSlice('model', model, handles);
        end
    end
end
% switch on Model layer
if strcmp(obj_type_to, 'model'); 
    set(handles.modelShowCheck,'value',1); 
    handles.Img{handles.Id}.I.modelExist = 1;
end;
% switch on Mask layer
if strcmp(obj_type_to, 'mask'); 
    set(handles.maskShowCheck,'value',1); 
    handles.Img{handles.Id}.I.maskExist = 1;
end;
if switch3d; delete(wb); toc(t1); end;
handles.Img{handles.Id}.I.plotImage(handles.imageAxes, handles, 0);
end