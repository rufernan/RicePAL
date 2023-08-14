
function [norm_s2_img_4D] = normalize_s2_imgs(s2_imgs_4D, norm_type)   

    if nargin<16
        norm_type = 'regular'; % 'regular', 'rad2ref'
    end

    norm_s2_img_4D = zeros(size(s2_imgs_4D));
    
    [~,~,num_bands,num_images] = size(s2_imgs_4D);           
    max_val = max(s2_imgs_4D(:));
    min_val = min(s2_imgs_4D(:));

    if strcmpi(norm_type,'rad2ref') % radiance to reflectance 
        
        % https://forum.step.esa.int/t/dn-to-reflectance/15763/8
        % https://gis.stackexchange.com/questions/233874/what-is-the-range-of-values-of-sentinel-2-level-2a-images  
        
        for i=1:num_images
            for b=1:num_bands
                norm_s2_img_4D(:,:,b,i) = s2_imgs_4D(:,:,b,i)/10000; 
            end
        end
    
    
    else % standard normalization [0,1]
        
        for i=1:num_images
            for b=1:num_bands
                norm_s2_img_4D(:,:,b,i) = (s2_imgs_4D(:,:,b,i) - min_val) / (max_val-min_val);
            end
        end
        
    end
    
end
