
function [filtered_cell_array, filtered_cell_climate, filtered_cell_soil, filtered_cell_labels]  = grep_cell_regression(cell_array, str, cell_climate, cell_soil, cell_labels)
    filtered_cell_array = {};
    filtered_cell_climate = {};
    filtered_cell_soil = {};
    filtered_cell_labels = {};
    num = 0;
    for i=1:numel(cell_array)
        if strfind(cell_array{i},str)
            num = num+1;
            filtered_cell_array{num,1} = cell_array{i};
            filtered_cell_climate{num,1} = cell_climate{i};
            filtered_cell_soil{num,1} = cell_soil{i};
            filtered_cell_labels{num,1} = cell_labels{i};
        end
    end

end
