
function [rmse,rmse_ha,mae,mae_ha] = evaluate_model_with_test_data(model, Xtst, Ytst, NORM_LABELS, max_lab, min_lab, OUTPUT_FOLDER, id, file_XY)

    disp('--Classifying test data...');
    Ytst_pred = predict(model,Xtst);
    if NORM_LABELS
        Ytst_pred = max(Ytst_pred,0); % clip the output [0,1]
        Ytst_pred = min(Ytst_pred,1);
        Ytst_pred = single(Ytst_pred)*(max_lab-min_lab) + min_lab; % de-normalizing the production values [min_lab,max_lab]
        Ytst = single(Ytst)*(max_lab-min_lab) + min_lab;            
    end       

    disp('--Computing numerical results...');
    % file_metrics = fullfile(OUTPUT_FOLDER, [id,'-',strrep(file_XY,'_XY.mat','_metrics.txt')]);    
    % [rmse,rmse_ha,mae,mae_ha] = compute_metrics_regression(Ytst_pred, Ytst, file_metrics);
    [rmse,rmse_ha,mae,mae_ha] = compute_metrics_regression(Ytst_pred, Ytst); % without generating an output file
    
end
 
