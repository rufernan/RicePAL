close all; clearvars;

addpath(genpath('./utils'));
diary([mfilename,'.txt']); diary on;

%% Script to extract the data patches for the experiments from the original Sentinel-2 data

all_years = {'2016','2017','2018'};
all_months = {'01jul','02sep','03nov'}; % we consider the samples per year and the months as temporal series (stacked into the 3D volume)
all_tiles = {'T44RMT','T44RMS','T44RNS','T44RPS','T44RNR','T44RPR','T44RQR','T45RTL','T45RUL','T45RTK','T45RUK','T45RVK','T45RWK','T45RXK'};

% Default input folder './data' (see 'grep_cell_regression')
OUTPUT_FOLDER = './01_patches';

TEST_PERCENT = 0.5;
PATCH_SIZES = [33]; % list of patch sizes to consider (e.g. [9,15,21])
STEP = 3; % fixed manually to extract over 100k patches in total (tra+tst) when considering all the years/months*/tiles *(we don't consider '01jul' because of the clouds)

% Global parameters
PURE_PATCHES = 0; % for considering only those patches with the neighborhood of the same class (only valid for classification)
ALLOW_MISSING_DATA = false; % to allow clouds or pixels outside the region of interest within each patch
NORM = 1; % for normalizing the data [0,1] (this is automatically done by the InputLayer of the network)
SELECTED_BANDS = 1:10; % band #11 is the cloud confidence map and band #12 is the NDVI map
B2R = 250; % border to remove overlap between tiles 500-pixel overlap
VARY_GT_PROD = 0.0; % percentage to modify the ground-truth rice production values according to the NDVI map
NORM_LABELS = false; % to normalize the regresion values to the [0,1] range



%% EXPERIMENT 1 %%

id = 'exp1';

years = all_years;
months = all_months;
tiles = all_tiles;

for s=1:numel(PATCH_SIZES) % iterating over patch sizes
    
    PATCH_SIZE = PATCH_SIZES(s); % patch size (neighborhood)       
    
    %%{
    %% Regressors
    model_name = 'lin';    
    output_file_name = save_patches(OUTPUT_FOLDER,years,months,tiles,id,TEST_PERCENT,PURE_PATCHES,ALLOW_MISSING_DATA,NORM,SELECTED_BANDS,B2R,VARY_GT_PROD,NORM_LABELS,PATCH_SIZE,STEP,model_name);        
    %{
    % ... the input data format is the same for the other regressors
    copyfile(output_file_name,strrep(output_file_name,model_name,'rid'));
    copyfile(output_file_name,strrep(output_file_name,model_name,'svr'));
    copyfile(output_file_name,strrep(output_file_name,model_name,'gpr'));
    copyfile(output_file_name,strrep(output_file_name,model_name,'brt'));
    %}
    
    %%{
    %% CNN-2D
    model_name = 'basic';    
    save_patches(OUTPUT_FOLDER,years,months,tiles,id,TEST_PERCENT,PURE_PATCHES,ALLOW_MISSING_DATA,NORM,SELECTED_BANDS,B2R,VARY_GT_PROD,NORM_LABELS,PATCH_SIZE,STEP,model_name);
    
   %% CNN-3D
    model_name = 'rusello18';
    save_patches(OUTPUT_FOLDER,years,months,tiles,id,TEST_PERCENT,PURE_PATCHES,ALLOW_MISSING_DATA,NORM,SELECTED_BANDS,B2R,VARY_GT_PROD,NORM_LABELS,PATCH_SIZE,STEP,model_name);
   %%}
    
end


diary off;






function save_file_data = save_patches(OUTPUT_FOLDER,years,months,tiles,id,TEST_PERCENT,PURE_PATCHES,ALLOW_MISSING_DATA,NORM,SELECTED_BANDS,B2R,VARY_GT_PROD,NORM_LABELS,PATCH_SIZE,STEP,model_name)

    id_exp = [id,'_',model_name,'_P',num2str(PATCH_SIZE),'_S',num2str(STEP)];
    disp(['Running ',id_exp,'...'])   

    disp('Extracting file names...');
    [files_s2, files_climate, files_soil, files_gt] = generate_file_names_regression(years, months, tiles);
    
    list_year_patches = {};
    list_labs_patches = {};
    
    disp('Processing data...');
    for y=1:numel(years)
        for t=1:numel(tiles)
            
            % Filtering the files for one year and tile
            [files_s2_year_tile, files_climate_year_tile, files_soil_year_tile, files_gt_year_tile] = grep_cell_regression(files_s2, years{y}, files_climate, files_soil, files_gt);
            [files_s2_year_tile, files_climate_year_tile, files_soil_year_tile, files_gt_year_tile] = grep_cell_regression(files_s2_year_tile, tiles{t}, files_climate_year_tile, files_soil_year_tile, files_gt_year_tile);
            
            if numel(files_s2_year_tile)~=numel(months) % we avoid the tiles with some missing products in all the months
                disp(strcat('Missing products for tile ', tiles{t}, '!'));
                continue;
            end
            
            year_tile_months_s2 = [];
            year_tile_months_clim = [];
            year_tile_months_soil = [];
            year_tile_months_gt = [];
            for m=1:numel(months) % iterating over months
                
                % Filtering the files of the month
                [files_s2_year_tile_month, files_climate_year_tile_month, files_soil_year_tile_month, files_gt_year_tile_month] = grep_cell_regression(files_s2_year_tile, months{m}, files_climate_year_tile, files_soil_year_tile, files_gt_year_tile);
                
                % Loading s2 product and gt (the ground-truth also includes the NDVI filtering)
                disp(files_s2_year_tile_month);
                [s2,clim,soil,gt] = load_tile_regression(files_s2_year_tile_month{1}, files_climate_year_tile_month{1}, files_soil_year_tile_month{1}, files_gt_year_tile_month{1}, B2R, VARY_GT_PROD);
                
                % Concatenating multitemporal images and gt files
                year_tile_months_s2(:,:,:,m) = single(s2(:,:,SELECTED_BANDS)); % filtering bands (to remove the cloud confidence and NDVI map)
                year_tile_months_clim(:,:,:,m) = clim;
                year_tile_months_soil(:,:,:,m) = soil; % the soil data is the same for all the months in a year
                year_tile_months_gt(:,:,m) = gt; % the production data is the same for all the months in a year
            end
            clear s2 clim soil gt;
            
            % We chose the "modified" ground-truth of Semptember because it has the most reliable NDVI estimation
            % Also we put nan values wherever they are within the data cube
            ind_sep = find(strcmp(months,'02sep'));
            gt = year_tile_months_gt(:,:,ind_sep);
            num_nans = sum(isnan(year_tile_months_gt),3);
            gt(num_nans>0) = nan;
            
            % Normalizing a set of images if appropriate
            if NORM
                year_tile_months_s2 = normalize_s2_imgs(year_tile_months_s2);
                % climate and soil data are globally normalized!
                year_tile_months_clim = normalize_s2_imgs(year_tile_months_clim);
                year_tile_months_soil = normalize_s2_imgs(year_tile_months_soil);
            end
            
            % Put all the bands together for the regression
            year_tile_months_s2 = order_bands_regression(year_tile_months_s2, year_tile_months_clim, year_tile_months_soil, model_name);
            
            [s2,labs] = extract_patches(year_tile_months_s2, gt, PATCH_SIZE, model_name, STEP, PURE_PATCHES, ALLOW_MISSING_DATA);
            % s2   --> [num_patches x PATCH_SIZE x PATCH_SIZE x num_bands*num_months]
            % labs --> [num_patches x 1] [0,254]->rice_production, 255->Nan
            clear year_tile_months_s2 year_tile_months_clim soil year_tile_months_soil;
            
            list_year_patches{y,t} = s2;
            list_labs_patches{y,t} = labs;
            
        end
    end
    
    all_tra_data = cat(1,list_year_patches{:});
    all_tra_labs = cat(1,list_labs_patches{:});
    clear list_year_patches list_labs_patches;
    
    min_lab = min(all_tra_labs(:));
    max_lab = max(all_tra_labs(:));
    if NORM_LABELS
        all_tra_labs = (single(all_tra_labs)-min_lab)/(max_lab-min_lab); % normalizing the production values [0,1]
    end
    
    [Xtra,Ytra,Xtst,Ytst] = split_patches_regression(all_tra_data, all_tra_labs, TEST_PERCENT, model_name);
    clear all_tra_data all_tra_labs;
    
    disp('Saving the generated data...');
    save_file_data = fullfile(OUTPUT_FOLDER,strcat(id_exp,'_XY.mat'));
    save(save_file_data,'Xtra','Ytra','Xtst','Ytst', 'min_lab', 'max_lab', '-v7.3');

end


