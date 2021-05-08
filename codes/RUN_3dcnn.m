close all; clearvars;

diary([mfilename,'.txt']); diary on;

model_name = '3dcnn';

INPUT_FOLDER = '../data';
OUTPUT_FOLDER = ['./RUN_',model_name,'_results']; 

EPOCHS = 100;
LEARN_RATE = 0.001;
GPU = 2; % 1->GTX2080Ti, 2->GTX1080Ti

disp('3D-CNN EXPERIMENTS');

file_XY = 'exp1_3dcnn_P33_S3_XY.mat'; disp(file_XY);
load(fullfile(INPUT_FOLDER, file_XY)) % 'Xtra','Ytra','Xtst','Ytst','min_lab','max_lab'
NORM_LABELS = max(Ytra(:))==1;

Xtra_all = Xtra; % full data (S/P/E-S2+Clim+Soil)
Xtst_all = Xtst;

DATA_TYPES = {...
    'S-S2','S-S2+Clim','S-S2+Soil','S-S2+Clim+Soil', ...
    'P-S2','P-S2+Clim','P-S2+Soil','P-S2+Clim+Soil', ...
    'E-S2','E-S2+Clim','E-S2+Soil','E-S2+Clim+Soil', ...
    'S/P-S2','S/P-S2+Clim','S/P-S2+Soil','S/P-S2+Clim+Soil', ...
    'P/E-S2','P/E-S2+Clim','P/E-S2+Soil','P/E-S2+Clim+Soil', ...
    'S/E-S2','S/E-S2+Clim','S/E-S2+Soil','S/E-S2+Clim+Soil', ...
    'S/P/E-S2','S/P/E-S2+Clim','S/P/E-S2+Soil','S/P/E-S2+Clim+Soil'
    };

PATCH_SIZES = [9,15,21,27,33] ;   
    
NUM_DATA_TYPES = numel(DATA_TYPES);
NUM_PATCHES = numel(PATCH_SIZES);
NUM_METRICS = 4; % rmse,rmse_ha,mae,mae_ha
RESULTS = zeros(NUM_DATA_TYPES,NUM_PATCHES,NUM_METRICS);
MODELS = cell(NUM_DATA_TYPES,NUM_PATCHES); 


for i=1:NUM_DATA_TYPES
    
    disp(['DATA--> "', DATA_TYPES{i},'"']);
        
    for j=1:NUM_PATCHES

        disp(['PATCH--> "', num2str(PATCH_SIZES(j)),'"']);
        
        [Xtra,Xtst] = filter_data(Xtra_all,Xtst_all,DATA_TYPES{i},PATCH_SIZES(j));
        
        disp(model_name);        
        disp('--Creating the model...');
        input_size = size(Xtra);   
        [layers, options] = create_model_regression(input_size(1:end-1), Xtst, Ytst, model_name, EPOCHS, LEARN_RATE);
        
        gpuDevice(GPU); % selecting the GPU          
        try % https://es.mathworks.com/matlabcentral/answers/433944-how-can-i-fix-the-cudnn-errors-when-i-m-running-train-with-rtx-2080
            nnet.internal.cnngpu.reluForward(1);
        catch ME
        end

        disp('--Training the model...');
        model = trainNetwork(Xtra,Ytra,layers,options);    

        %{
        % saving the training window (only valid when setting 'Plots' to 'training-progress' in trainNetwork options) 
        h = findall(groot,'Type','Figure');
        h = h(end);
        h.MenuBar = 'figure'; 
        print(h,fullfile(OUTPUT_FOLDER, [num2str(i,"%02d"),'_',strrep(DATA_TYPES{i},'/','_'),'_',num2str(PATCH_SIZES(j)),'_training.png']),'-dpng');
        close(h);
        %}
        
        [rmse,rmse_ha,mae,mae_ha] = evaluate_model_with_test_data(model, Xtst, Ytst, NORM_LABELS, max_lab, min_lab, OUTPUT_FOLDER, '1', file_XY);  
        RESULTS(i,j,:) = [rmse,rmse_ha,mae,mae_ha];
        MODELS{i,j} = model;
    
    end

end

save(fullfile(OUTPUT_FOLDER,'RESULTS_data_methods_metrics.mat'),'RESULTS');
save(fullfile(OUTPUT_FOLDER,'MODELS_data_methods.mat'),'MODELS','-v7.3');


diary off;
