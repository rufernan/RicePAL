
% function [rmse] = compute_metrics_regression(pred_vals, real_vals, save_file_metrics)
function [rmse,rmse_ha,mae,mae_ha] = compute_metrics_regression(pred_vals, real_vals, save_file_metrics)

    % Default parameters    
    if nargin<3
        save_file_metrics = '';
    end
    
%     1 bushels per acre= 67.25 kg/ha
    rmse = calc_RMSE(pred_vals,real_vals);
    rmse_ha = 25*rmse;
    mae = calc_MAE(pred_vals,real_vals);
    mae_ha = 25*mae;
    
    if save_file_metrics        
        fileID = fopen(save_file_metrics,'w');
        fprintf(fileID,(strcat('rmse=[',num2str(rmse),']\n')));
        fprintf(fileID,(strcat('rmse_ha=[',num2str(rmse_ha),']\n')));
        fprintf(fileID,(strcat('mae=[',num2str(mae),']\n')));
        fprintf(fileID,(strcat('mae_ha=[',num2str(mae_ha),']\n')));
        
        
        fclose(fileID);
    end

end



function rmse=calc_RMSE(est_vals, gt_vals)
    vec_est_vals = double(est_vals(:));
    vec_gt_vals = double(gt_vals(:));
    rmse = sqrt( sum((vec_est_vals - vec_gt_vals).^2) / numel(vec_est_vals) );
end

function mae=calc_MAE(est_vals, gt_vals)
    vec_est_vals = double(est_vals(:));
    vec_gt_vals = double(gt_vals(:));
    mae = sum(abs(vec_est_vals - vec_gt_vals)) / numel(vec_est_vals);
end


