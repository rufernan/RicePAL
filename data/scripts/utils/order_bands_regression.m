
function output_image  = order_bands_regression(input_image_4D, input_climate_4D, input_soil_4D, model_name)    

    % For each timestamp, we stack all the bands of the different data sources together               
    
    if nargin<2
        model_name = 'basic';
    end

    load_configuration;
    % loading these two varaibles from the configuration file
    % MODEL_NAMES_3D_VOLUME = {'svr', 'rf', 'mlp', 'basic'};
    % MODEL_NAMES_4D_VOLUME = {'rusello18','rusello18new'};
    
    [~,~,B,T] = size(input_image_4D); % 10 bands        
    [~,~,B_clim,~] = size(input_climate_4D);  % 4 bands
    [~,~,B_soil,~] = size(input_soil_4D);  % 6 bands
    

    %% SVM, MLP and CNN-2D (stacking corresponding temporal bands into a 3D volume)    
    if any(contains(MODEL_NAMES_3D_VOLUME,model_name))
        i=0;
        for t=1:T
            for b=1:B   % S2 image
                i=i+1;
                output_image(:,:,i) = single(input_image_4D(:,:,b,t));
            end
%             for b=1:B_clim   % Climate data
%                 i=i+1;
%                 output_image(:,:,i) = single(input_climate_4D(:,:,b,t));
%             end
%             for b=1:B_soil  % Soil data
%                 i=i+1;
%                 output_image(:,:,i) = single(input_soil_4D(:,:,b,t));
%             end
            for b=1:B_clim   % Climate data
                i=i+1;
                output_image(:,:,i) = single(input_climate_4D(:,:,b,t));
            end
            for b=1:B_soil  % Soil data
                i=i+1;
                output_image(:,:,i) = single(input_soil_4D(:,:,b,t));
            end
        end
            
    %% CNN-3D (stacking corresponding temporal bands into a 4th dimension)
    elseif any(contains(MODEL_NAMES_4D_VOLUME,model_name))
        for t=1:T
            i=0;
            for b=1:B
                i=i+1;
                output_image(:,:,t,i) = single(input_image_4D(:,:,b,t));
            end
%             for b=1:B_clim
%                 i=i+1;
%                 output_image(:,:,t,i) = single(input_climate_4D(:,:,b,t));
%             end
%             for b=1:B_soil
%                 i=i+1;
%                 output_image(:,:,t,i) = single(input_soil_4D(:,:,b,t));
%             end
            for b=1:B_clim
                i=i+1;
                output_image(:,:,t,i) = single(input_climate_4D(:,:,b,t));
            end
            for b=1:B_soil
                i=i+1;
                output_image(:,:,t,i) = single(input_soil_4D(:,:,b,t));
            end

        end        
    end   
    
end
