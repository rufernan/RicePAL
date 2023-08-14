function [s2_img_tile, climate_map, soil_map, rice_production_map] = load_tile_regression(filename_s2_img_tile, filename_climate, filename_soil, filename_production, B2R, VARY_GT_PROD)

    if nargin<5
        B2R = 0; % border to remove
    end    
    if nargin<5
        VARY_GT_PROD = 0; % in order to slightly modify the ground-truth production values according to the average NDVI value of the tile
    end    

    % Reading the S2 image tile
    [A,R] = geotiffread(filename_s2_img_tile);
    A = A(B2R+1:end-B2R,B2R+1:end-B2R,:);   
    
    % Reading the climate data
    [A1,R1] = geotiffread(filename_climate);
    A1 = A1(B2R+1:end-B2R,B2R+1:end-B2R,:);   
    
    % Reading the soil data
    [A2,R2] = geotiffread(filename_soil);
    A2 = A2(B2R+1:end-B2R,B2R+1:end-B2R,:);   
    
    % Reading ground-truth rice production map for the corresponding S2 image tile
    [A_gt,R_gt] = geotiffread(filename_production);
    A_gt = A_gt(B2R+1:end-B2R,B2R+1:end-B2R,:);
        
    % Class labels    
    A_gt_labs = double(A_gt);
    % 0          -> pixel with no rice
    % (0,255) -> rice production for a rice pixel    
    % 255      -> pixel outside the region of interest   
    
    % In the production maps the '255' value is used to identify the
    % 'no_data' situation since the uniform production values are always 
    % below this number. Hovewer, when modifying the unifor distribution 
    % according to the NDVI, it is possible to get some higher values.
    % So, we use 'nan' instead of '255'.
    
    no_data = nan; % we use 'nan' for no_data value         
    A_gt_labs(A_gt_labs==255) = no_data;
    
    ndvi_map = A(:,:,end); % corresponding NDVI map
    
    if VARY_GT_PROD>0 % introducing some variations on the ground-truth production values            
        [A_gt_labs] = modify_gt_rice_production(A_gt_labs, ndvi_map, VARY_GT_PROD);       
    end      
    
    % Filter labels by NDVI (removing water)    
    % ndvi<0.1 water and others (https://www.sentinel-hub.com/eoproducts/ndvi-normalized-difference-vegetation-index)
    is_water_or_nan = or(ndvi_map<0.1,isnan(ndvi_map));
    labels = A_gt_labs;
    labels(is_water_or_nan) = no_data;
    
    s2_img_tile = A;
    climate_map = A1;
    soil_map = A2;
    rice_production_map = labels;

end
