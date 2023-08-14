
function [new_gt_prod] = modify_gt_rice_production(gt_prod, ndvi_map, VARY_GT_PROD)   

    % In the ground-truth rice production, we assume an uniform distribution
    % for each district, however this is not a real assumption since the
    % vegetation content may significantly vary from pixel to pixel.
    % To introduce more variety in the regression values, we make use of
    % the corresponding NDVI map in the following way:
    %  - For each product, we compute the average NDVI of the rice pixels
    %  - For each rice pixel, we proportionally modify its production value
    %  according to the average NDVI of the product (tile).
    % Note that we work at tile level in order not to complicate the code

    % VARY_GT_PROD is a percentage [0,1] for controling the influence of the 
    % NDVI map on the rice production value
    
    % Note that 'gt_prod' contains 'nan' values for those pixels outside
    % the resion of interest.
    
    rice_mask = logical( uint8(gt_prod>0) .* uint8(not(isnan(gt_prod))) );
    rice_mask_vec = rice_mask(:);    
    ndvi_map_vec = ndvi_map(:); % NaN outside the region of interest       
    avg_ndvi_rice = nanmean(ndvi_map_vec(rice_mask_vec));
    
    max_ndvi_rice = max(ndvi_map_vec(rice_mask_vec));
    min_ndvi_rice = 0.1; % min ndvi not to be clouds/water
      
    new_gt_prod = single(gt_prod);
    for i=1:size(new_gt_prod,1)
        for j=1:size(new_gt_prod,2)
            if new_gt_prod(i,j)>0 && not(isnan(new_gt_prod(i,j))) && not(ndvi_map(i,j)<0.1) % 0-->no rice, nan-->outside the region of interest, ndvi<0.1-->clouds/water
                factor = ndvi_map(i,j)/avg_ndvi_rice;
                if factor>1 % increase the production
                    new_gt_prod(i,j) = new_gt_prod(i,j) + new_gt_prod(i,j)* (ndvi_map(i,j)/max_ndvi_rice) * VARY_GT_PROD;
                elseif factor==1 % the production remains same
                    new_gt_prod(i,j) = new_gt_prod(i,j);
                else % decrease the production
                    new_gt_prod(i,j) = new_gt_prod(i,j) - new_gt_prod(i,j)*factor * VARY_GT_PROD;
%                 elseif factor<0 % decrease the production
%                     new_gt_prod(i,j) = new_gt_prod(i,j) - new_gt_prod(i,j)* (min_ndvi_rice/ndvi_map(i,j)) * VARY_GT_PROD;
                end
            end
        end
    end
    
end
