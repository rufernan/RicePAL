
function [Xtra,Xtst] = filter_data(Xtra_all,Xtst_all,DATA_TYPE,PATCH_SIZE)

    if nargin<4
        PATCH_SIZE = 0;
    end       

    if ndims(Xtra_all)<5 % ndims(Xtra_all)==2 or ndims(Xtra_all)==4
    
        % Xtra_all, Xtra_all --> [PatchSize,PatchSize,60,NumPatches]
        %                        60bands--> 20 SoS (10 S2 + 4 Clim + 6 Soil), 20 PoS and 20 EoS

        if strcmpi(DATA_TYPE, 'S/P/E-S2+Clim+Soil')
            BANDS = [1:10, 11:14, 15:20, 21:30, 31:34, 35:40, 41:50, 51:54, 55:60];
        elseif strcmpi(DATA_TYPE, 'S/P/E-S2+Soil')
            BANDS = [1:10, 15:20, 21:30, 35:40, 41:50, 55:60];
        elseif strcmpi(DATA_TYPE, 'S/P/E-S2+Clim')
            BANDS = [1:10, 11:14, 21:30, 31:34, 41:50, 51:54];
        elseif strcmpi(DATA_TYPE, 'S/P/E-S2')
            BANDS = [1:10, 21:30, 41:50];

        elseif strcmpi(DATA_TYPE, 'S/E-S2+Clim+Soil')
            BANDS = [1:10, 11:14, 15:20, 41:50, 51:54, 55:60];
        elseif strcmpi(DATA_TYPE, 'S/E-S2+Soil')
            BANDS = [1:10, 15:20, 41:50, 55:60];
        elseif strcmpi(DATA_TYPE, 'S/E-S2+Clim')
            BANDS = [1:10, 11:14, 41:50, 51:54];
        elseif strcmpi(DATA_TYPE, 'S/E-S2')
            BANDS = [1:10, 41:50];            

        elseif strcmpi(DATA_TYPE, 'P/E-S2+Clim+Soil')
            BANDS = [21:30, 31:34, 35:40, 41:50, 51:54, 55:60];
        elseif strcmpi(DATA_TYPE, 'P/E-S2+Soil')
            BANDS = [21:30, 35:40, 41:50, 55:60];
        elseif strcmpi(DATA_TYPE, 'P/E-S2+Clim')
            BANDS = [21:30, 31:34, 41:50, 51:54];
        elseif strcmpi(DATA_TYPE, 'P/E-S2')
            BANDS = [21:30, 41:50];            

        elseif strcmpi(DATA_TYPE, 'S/P-S2+Clim+Soil')
            BANDS = [1:10, 11:14, 15:20, 21:30, 31:34, 35:40];
        elseif strcmpi(DATA_TYPE, 'S/P-S2+Soil')
            BANDS = [1:10, 15:20, 21:30, 35:40];
        elseif strcmpi(DATA_TYPE, 'S/P-S2+Clim')
            BANDS = [1:10, 11:14, 21:30, 31:34];
        elseif strcmpi(DATA_TYPE, 'S/P-S2')
            BANDS = [1:10, 21:30];                         

        elseif strcmpi(DATA_TYPE, 'E-S2+Clim+Soil')
            BANDS = [41:50, 51:54, 55:60];
        elseif strcmpi(DATA_TYPE, 'E-S2+Soil')
            BANDS = [41:50, 55:60];
        elseif strcmpi(DATA_TYPE, 'E-S2+Clim')
            BANDS = [41:50, 51:54];
        elseif strcmpi(DATA_TYPE, 'E-S2')
            BANDS = [41:50];

        elseif strcmpi(DATA_TYPE, 'P-S2+Clim+Soil')
            BANDS = [21:30, 31:34, 35:40];
        elseif strcmpi(DATA_TYPE, 'P-S2+Soil')
            BANDS = [21:30, 35:40];
        elseif strcmpi(DATA_TYPE, 'P-S2+Clim')
            BANDS = [21:30, 31:34];
        elseif strcmpi(DATA_TYPE, 'P-S2')
            BANDS = [21:30];    

        elseif strcmpi(DATA_TYPE, 'S-S2+Clim+Soil')
            BANDS = [1:10, 11:14, 15:20];
        elseif strcmpi(DATA_TYPE, 'S-S2+Soil')
            BANDS = [1:10, 15:20];
        elseif strcmpi(DATA_TYPE, 'S-S2+Clim')
            BANDS = [1:10, 11:14];
        elseif strcmpi(DATA_TYPE, 'S-S2')
            BANDS = [1:10];           
        end


        if ismatrix(Xtra_all)
            Xtra = Xtra_all(:,BANDS);
            Xtst = Xtst_all(:,BANDS);

        else

            if PATCH_SIZE
                b2s = floor( (size(Xtra_all,1)-PATCH_SIZE)/2 ); % border to shave
            else 
                b2s = 0;
            end

            Xtra = Xtra_all(b2s+1:end-b2s, b2s+1:end-b2s, BANDS, :);
            Xtst = Xtst_all(b2s+1:end-b2s, b2s+1:end-b2s, BANDS, :);

        end

       
        
    else % ndims(Xtra)==5
        
        if strcmpi(DATA_TYPE, 'S/P/E-S2+Clim+Soil')
            TIME = [1,2,3];
            BANDS = [1:10, 11:14, 15:20];
        elseif strcmpi(DATA_TYPE, 'S/P/E-S2+Soil')
            TIME = [1,2,3];
            BANDS = [1:10, 15:20];
        elseif strcmpi(DATA_TYPE, 'S/P/E-S2+Clim')
            TIME = [1,2,3];
            BANDS = [1:10, 11:14];
        elseif strcmpi(DATA_TYPE, 'S/P/E-S2')
            TIME = [1,2,3];
            BANDS = [1:10];
            
        elseif strcmpi(DATA_TYPE, 'S/E-S2+Clim+Soil')
            TIME = [1,3];
            BANDS = [1:10, 11:14, 15:20];
        elseif strcmpi(DATA_TYPE, 'S/E-S2+Soil')
            TIME = [1,3];
            BANDS = [1:10, 15:20];
        elseif strcmpi(DATA_TYPE, 'S/E-S2+Clim')
            TIME = [1,3];
            BANDS = [1:10, 11:14];
        elseif strcmpi(DATA_TYPE, 'S/E-S2')
            TIME = [1,3];
            BANDS = [1:10];
            
        elseif strcmpi(DATA_TYPE, 'P/E-S2+Clim+Soil')
            TIME = [2,3];
            BANDS = [1:10, 11:14, 15:20];
        elseif strcmpi(DATA_TYPE, 'P/E-S2+Soil')
            TIME = [2,3];
            BANDS = [1:10, 15:20];
        elseif strcmpi(DATA_TYPE, 'P/E-S2+Clim')
            TIME = [2,3];
            BANDS = [1:10, 11:14];
        elseif strcmpi(DATA_TYPE, 'P/E-S2')
            TIME = [2,3];
            BANDS = [1:10];
            
        elseif strcmpi(DATA_TYPE, 'S/P-S2+Clim+Soil')
            TIME = [1,2];
            BANDS = [1:10, 11:14, 15:20];
        elseif strcmpi(DATA_TYPE, 'S/P-S2+Soil')
            TIME = [1,2];
            BANDS = [1:10, 15:20];
        elseif strcmpi(DATA_TYPE, 'S/P-S2+Clim')
            TIME = [1,2];
            BANDS = [1:10, 11:14];
        elseif strcmpi(DATA_TYPE, 'S/P-S2')
            TIME = [1,2];
            BANDS = [1:10];
            
        elseif strcmpi(DATA_TYPE, 'E-S2+Clim+Soil')
            TIME = [3];
            BANDS = [1:10, 11:14, 15:20];
        elseif strcmpi(DATA_TYPE, 'E-S2+Soil')
            TIME = [3];
            BANDS = [1:10, 15:20];
        elseif strcmpi(DATA_TYPE, 'E-S2+Clim')
            TIME = [3];
            BANDS = [1:10, 11:14];
        elseif strcmpi(DATA_TYPE, 'E-S2')
            TIME = [3];
            BANDS = [1:10];
            
        elseif strcmpi(DATA_TYPE, 'P-S2+Clim+Soil')
            TIME = [2];
            BANDS = [1:10, 11:14, 15:20];
        elseif strcmpi(DATA_TYPE, 'P-S2+Soil')
            TIME = [2];
            BANDS = [1:10, 15:20];
        elseif strcmpi(DATA_TYPE, 'P-S2+Clim')
            TIME = [2];
            BANDS = [1:10, 11:14];
        elseif strcmpi(DATA_TYPE, 'P-S2')
            TIME = [2];
            BANDS = [1:10];
            
        elseif strcmpi(DATA_TYPE, 'S-S2+Clim+Soil')
            TIME = [1];
            BANDS = [1:10, 11:14, 15:20];
        elseif strcmpi(DATA_TYPE, 'S-S2+Soil')
            TIME = [1];
            BANDS = [1:10, 15:20];
        elseif strcmpi(DATA_TYPE, 'S-S2+Clim')
            TIME = [1];
            BANDS = [1:10, 11:14];
        elseif strcmpi(DATA_TYPE, 'S-S2')
            TIME = [1];
            BANDS = [1:10];
        end        
        
        if PATCH_SIZE
            b2s = floor( (size(Xtra_all,1)-PATCH_SIZE)/2 ); % border to shave
        else
            b2s = 0;
        end
        
        Xtra = Xtra_all(b2s+1:end-b2s, b2s+1:end-b2s, TIME, BANDS, :);
        Xtst = Xtst_all(b2s+1:end-b2s, b2s+1:end-b2s, TIME, BANDS, :);
                
    end
        
end 
