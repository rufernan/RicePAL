
function [PATCHES1,LABELS1,PATCHES2,LABELS2] = split_patches_regression(patches, labels, PERCENT, model_name, rand_seed)

    % Importat: we assume patches --> [num_patches x PATCH_SIZE x PATCH_SIZE x num_bands]

    if nargin<3
        PERCENT = 0.5; % 50%
    end
    if nargin<4
        model_name = 'basic'; 
    end
    if nargin<5
        rand_seed = 0; 
    end

    load_configuration;
    % loading these two varaibles from the configuration file
    % MODEL_NAMES_3D_VOLUME = {'lin', 'rid', 'svr', 'gpr', 'brt', 'basic'};
    % MODEL_NAMES_4D_VOLUME = {'rusello18'}; 
    
    TOTAL = size(patches,1);
    NUM = ceil(TOTAL * PERCENT);
    
    rng(rand_seed); % for reproducibility
    
    if any(contains(MODEL_NAMES_3D_VOLUME,model_name))
    
        PATCHES = permute(patches, [2 3 4 1]); % in matlab samples last, in python samples first
        LABELS = single(labels); % to single precision float    

        idx = randperm(TOTAL,NUM);

        PATCHES1 = PATCHES;
        PATCHES2 = PATCHES1(:,:,:,idx);
        PATCHES1(:,:,:,idx) = [];

        LABELS1 = LABELS;
        LABELS2 = LABELS1(idx);
        LABELS1(idx) = [];      
        
        if strcmp(model_name,'lin') || strcmp(model_name,'rid') || strcmp(model_name,'svr') || strcmp(model_name,'gpr') || strcmp(model_name,'brt') % for LIN/SVM/GPR/BRT we have to vectorize the input data into a 2D matrix
            
            % Considering the whole patch
            %{
            PATCHES1 = permute(PATCHES1, [4 1 2 3]); % samples first for SVM
            [d1,d2,d3,d4] = size(PATCHES1);
            PATCHES1 = reshape(PATCHES1, [d1,prod([d2,d3,d4])]);
        
            PATCHES2 = permute(PATCHES2, [4 1 2 3]); % samples first for SVM
            [d1,d2,d3,d4] = size(PATCHES2);
            PATCHES2 = reshape(PATCHES2, [d1,prod([d2,d3,d4])]);
            %}
            
            % Only considering the pixel of interes (in depth)
            PATCHES1 = permute(PATCHES1, [4 1 2 3]); % samples first for SVM
            [d1,d2,d3,d4] = size(PATCHES1);
            patch_center = floor(d2);
            PATCHES1 = squeeze(PATCHES1(:,patch_center,patch_center,:));
            
            PATCHES2 = permute(PATCHES2, [4 1 2 3]); % samples first for SVM
            [d1,d2,d3,d4] = size(PATCHES2);
            patch_center = floor(d2);
            PATCHES2 = squeeze(PATCHES2(:,patch_center,patch_center,:));
            
        end
        
        
    elseif any(contains(MODEL_NAMES_4D_VOLUME,model_name))
        
        PATCHES = permute(patches, [2 3 4 5 1]); % in matlab samples last, in python samples first
        LABELS = single(labels); % to single precision float    
        
        idx = randperm(TOTAL,NUM);
        
        PATCHES1 = PATCHES;
        PATCHES2 = PATCHES1(:,:,:,:,idx);
        PATCHES1(:,:,:,:,idx) = [];
        
        LABELS1 = LABELS;
        LABELS2 = LABELS1(idx);
        LABELS1(idx) = [];
                
    end
    
end
