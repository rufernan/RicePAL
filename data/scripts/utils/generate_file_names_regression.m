function [files_s2, files_climate, files_soil, files_gt] = generate_file_names_regression(years, months, tile_names, data_folder, gt_folder_name)

    if nargin<1
        years = {'2016','2017','2018'};
    end
    if nargin<2
        months = {'01jul','02sep','03nov'};
    end
    if nargin<3
        tile_names = {};
    end 
    if nargin<4
        data_folder = './data';
    end
    if nargin<5
        gt_folder_name = fullfile(data_folder,'gt_rice'); 
        
    end
  

    files_s2 = {};
    files_climate = {};
    files_soil = {};
    files_gt = {};

    num_files = 0;
        
    for i=1:numel(years)
        
        for j=1:numel(months)
            
            files = dir(fullfile(data_folder,years{i},months{j},'*.tif'));
            if numel(tile_names)>0 % filtering the file names according to the provided tile names
                files = filter_files(files, tile_names);
            end

            for k=1:numel(files)
            
                num_files = num_files + 1;
            
                % name of the s2 product
                file_name = fullfile(files(k).folder,files(k).name);
                files_s2{num_files,1} = file_name;

                % extracting the corresponding tile name
                [filepath,name,ext] = fileparts(file_name);
                tile = strsplit(name,'_'); tile = strcat('*',tile{end},ext);
            
                % climate file
                file = dir(fullfile(data_folder,years{i},months{j},'climate',tile));
                file_name = fullfile(file(1).folder,file(1).name);
                files_climate{num_files,1} = file_name;
                if not(isfile(file_name))
                    error(strcat('Missing climate data! File ''',file_name,''' does not exist.'))
                end
                
                % soil file
                file = dir(fullfile(gt_folder_name,'soil',tile));
                file_name = fullfile(file(1).folder,file(1).name);
                files_soil{num_files,1} = file_name;
                if not(isfile(file_name))
                    error(strcat('Missing soil data! File ''',file_name,''' does not exist.'))
                end

                % gt production file
                file = dir(fullfile(gt_folder_name,'production',years{i},tile));
                file_name = fullfile(file(1).folder,file(1).name);
                files_gt{num_files,1} = file_name;
                if not(isfile(file_name))
                    error(strcat('Missing groud-truth production data! File ''',file_name,''' does not exist.'))
                end
                
            end

        end
    end

end
