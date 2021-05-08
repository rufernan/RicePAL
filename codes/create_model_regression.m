 
function [layers, options] = create_model_regression(input_size, Xval, Yval, model_name, EPOCHS, LEARN_RATE)

    
    if nargin<4
        model_name = '3dcnn';
    end
    if nargin<5
        EPOCHS = 100;
    end
    if nargin<6
        LEARN_RATE = 0.001;
    end
    
    
    
    % Proposed 3D-CNN regression network
    if strcmp(model_name,'3dcnn')
                
        ts = input_size(3); % 3rd dimension is the number of timestamp
        
    
        layers = [
            
        image3dInputLayer(input_size)
        %image3dInputLayer(input_size,'Normalization','none')
        
        % Since we have 'ts' timespamps we need to set the 3rd
        % dimension of the 3D kernel always to the 'ts' value, and also
        % removing the pooling in that 3rd dimension
                
        
        %% Convolutional layers
        
        % Conv_1
        convolution3dLayer([3,3,ts],64,'Padding',[1,1,1],'Stride',[1,1,1])
        batchNormalizationLayer
        reluLayer
        % Pool_1
        maxPooling3dLayer([2,2,1],'Stride',[1,1,1]) % we do not reduce the size in the 1st pooling
        
        % Conv_2
        convolution3dLayer([3,3,ts],128,'Padding',[1,1,1],'Stride',[1,1,1])
        batchNormalizationLayer
        reluLayer
        % Pool_2
        maxPooling3dLayer([2,2,1],'Stride',[2,2,1]) % we only reduce the spatial size in the 2nd pooling
        
        % Conv_3_a
        convolution3dLayer([3,3,ts],256,'Padding',[1,1,1],'Stride',[1,1,1])
        batchNormalizationLayer
        reluLayer
        % Conv_3_b
        convolution3dLayer([3,3,ts],256,'Padding',[1,1,1],'Stride',[1,1,1])
        batchNormalizationLayer
        reluLayer
        % Pool_3
        maxPooling3dLayer([2,2,1],'Stride',[2,2,1]) % we only reduce the spatial size in the 3rd pooling
        
        % Conv_4_a
        convolution3dLayer([3,3,ts],512,'Padding',[1,1,1],'Stride',[1,1,1])
        batchNormalizationLayer
        reluLayer
        % Conv_4_b
        convolution3dLayer([3,3,ts],512,'Padding',[1,1,1],'Stride',[1,1,1])
        batchNormalizationLayer
        reluLayer
        % Pool_4
        maxPooling3dLayer([2,2,ts],'Stride',[2,2,ts]) % we use the original pooling for the 4rd maxPooling (timestaps) in this layer
        
        
        %% Fully connected layers
        
        % Fc_5
        fullyConnectedLayer(1024)
        batchNormalizationLayer
        reluLayer
        % Fc_6
        fullyConnectedLayer(1)
        regressionLayer];
    
    
        options = trainingOptions('adam', ...
            'InitialLearnRate',LEARN_RATE, ... % 0.001
            'MaxEpochs',EPOCHS, ... % 100
            'Shuffle','every-epoch', ...
            'ValidationData',{Xval,Yval}, ...
            'ValidationFrequency',30, ...
            'MiniBatchSize',100, ...
            'SquaredGradientDecayFactor',0.999,...
            'ValidationPatience',100, ...
            'L2Regularization',0.000001, ...
            'Verbose',true);
            %'Verbose',false, ...
            %'Plots','training-progress');
                            

    end

    
    
end
