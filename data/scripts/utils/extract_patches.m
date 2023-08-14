
function [patches, labels, discard_data, discard_zeros, discard_nans, B_center] = extract_patches(s2_img_tile, tile_rice_map, PATCH_SIZE, model_name, STEP, PURE_PATCHES, ALLOW_MISSING_DATA, MAX_PATCH_PER_IMG, SAVE)

    load_configuration;
    % loading these two varaibles from the configuration file
    % MODEL_NAMES_3D_VOLUME = {'lin', 'rid', 'svm', 'gpr', 'brt', 'basic', 'zhang2018mapping', 'ji20183d-2D'};
    % MODEL_NAMES_4D_VOLUME = {'ji20183d-3D'};

    % This program characterizes each S2 pixel as a 3D patch

    % Important: here we assume for 'tile_rice_map' the class labes defined in 'load_tile.m'    
    neg_class=0; pos_class=1;
   
    % Default parameters    
    if nargin<3
        PATCH_SIZE = 15;
    end
    if nargin<4
        model_name = 'basic';
    end
    if nargin<5
        STEP = PATCH_SIZE; % by default we use 'distinct' patches
    end
    if nargin<6
        PURE_PATCHES = 1;
    end
    if nargin<7
        ALLOW_MISSING_DATA = 1; % 0->no missing data in the whole patch, 1->no missing data in the patch center, -1->allow all missing
                                % allow some mising data within the patch (if the patch venter is OK then extract the patch)
    end
    if nargin<8        
        MAX_PATCH_PER_IMG = 500;
    end        
    if nargin<9        
        SAVE = '';
    end        
    
    
    [rows,cols] = size(tile_rice_map);
        
    % extracting patches from 'tile_rice_map' likewise 'im2col'       
    disp('Processing the groud-truth data...');
    
    sample=0;
    B = zeros(floor(rows/STEP)*floor(cols/STEP),PATCH_SIZE*PATCH_SIZE);
    
    for i=1:STEP:cols
        for j=1:STEP:rows 
                        
            ini_col = i;
            end_col = ini_col + PATCH_SIZE -1;
            ini_row = j;
            end_row = ini_row + PATCH_SIZE -1;                        
            
            if end_row<=rows && end_col<=cols
                sample = sample+1;
                PATCH = tile_rice_map(ini_row:end_row, ini_col:end_col);
                B(sample,:) = PATCH(:)';                
            end
            
        end
    end

    if size(B,1)>sample % adjusting the size (because of the pre-allocation)
        B(sample+1:end,:) = [];
    end
    
    
    B_center = B(:,ceil((PATCH_SIZE^2)/2)); % label of the central pixel (pixel of interest)

    % in classification (2) and in regression (nan) means no data
    no_data = max(B(:)); % classification
    if no_data>2 % regression
        no_data = nan;
    end
    
    if ALLOW_MISSING_DATA==1
        if no_data==2 % classification
            discard_data = B_center==no_data; % removing those patches with missing only data in the central pixel (pixel of interest)
        else % regression (Nan/0 means outside-ROI/no-rice)
            discard_data = or(isnan(B_center),B_center==0);
        end
    elseif ALLOW_MISSING_DATA==0
        if no_data==2 % classification
            discard_data = sum(B==no_data,2)>0; % removing patches with some missing data
        else % regression (Nan/0)
            discard_data = or(sum(isnan(B),2)>0, B_center==0);
        end
    else % ALLOW_MISSING_DATA==-1
        discard_data =zeros(size(B_center));  
    end

    discard_zeros = sum(B==0,2)>0;
    discard_nans = sum(isnan(B),2)>0;
    
    if PURE_PATCHES % removing non-pure patches (ONLY VALID FOR CLASSIFICATION!)
        discard_no_pure_patches = or(sum(B==neg_class,2)<(PATCH_SIZE^2),sum(B==pos_class,2)<(PATCH_SIZE^2));
        discard_data = or(discard_data, discard_no_pure_patches);
    end

    % selecting a maximun number of patches
    num_patches = sum(discard_data==0);
    if(num_patches>MAX_PATCH_PER_IMG)
        num_to_discard = num_patches-MAX_PATCH_PER_IMG;
        selected_indexes = find(discard_data==0);
        extra_indexes_to_discard = randperm(num_patches,num_to_discard);
        discard_data(selected_indexes(extra_indexes_to_discard)) = 1;
    end    
    
    % creating the samples
    disp('Extracting patches from S2 products...');
       
    numPatches = sum(discard_data==0);    
    LABELS = zeros([numPatches,1]);
    
    if any(contains(MODEL_NAMES_3D_VOLUME,model_name))
        [rows,cols,bands] = size(s2_img_tile);
        SAMPLES = zeros([numPatches,PATCH_SIZE,PATCH_SIZE,bands]);
    elseif any(contains(MODEL_NAMES_4D_VOLUME,model_name))
        [rows,cols,time,bands] = size(s2_img_tile);
        SAMPLES = zeros([numPatches,PATCH_SIZE,PATCH_SIZE,time,bands]);
    end
        

    index=0;
    sample=0;
        
    for i=1:STEP:cols        
        for j=1:STEP:rows                                              
            
            ini_col = i;
            end_col = ini_col + PATCH_SIZE -1;
            ini_row = j;
            end_row = ini_row + PATCH_SIZE -1;
            
            if end_row<=rows && end_col<=cols
                
                index = index+1;
                
                if mod(index,10000)==0
                    disp(strcat(num2str(index),'/',num2str(size(B_center,1))));
                end
                
                % only considering selected patches
                if discard_data(index)==0
                    sample = sample+1;                    
                    
                    if any(contains(MODEL_NAMES_3D_VOLUME,model_name))
                        PATCH = s2_img_tile(ini_row:end_row, ini_col:end_col,:);
                        SAMPLES(sample,:,:,:) = PATCH;
                    elseif any(contains(MODEL_NAMES_4D_VOLUME,model_name))
                        PATCH = s2_img_tile(ini_row:end_row, ini_col:end_col,:,:);
                        SAMPLES(sample,:,:,:,:) = PATCH;
                    end
                    
                    LABELS(sample,1) = B_center(index,1);
                end
                
            end

        end
    end
           
    patches = SAMPLES;
    labels = LABELS;

    if SAVE
        save(SAVE,'patches','labels');
    end
    
    disp(strcat('Total extracted patches: ',num2str(numPatches)));

end
