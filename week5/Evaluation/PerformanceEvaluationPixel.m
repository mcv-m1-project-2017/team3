function [pixelPrecision, pixelAccuracy, pixelSensitivity, pixelF1] = PerformanceEvaluationPixel(pixelTP, pixelFP, pixelFN, pixelTN)
    % PerformanceEvaluationPixel
    % Function to compute different performance indicators (Precision, accuracy, 
    % sensitivity, F1) at the pixel level
    %
    %    Parameter name      Value
    %    --------------      -----
    %    'pixelTP'           Number of True  Positive pixels
    %    'pixelFP'           Number of False Positive pixels
    %    'pixelFN'           Number of False Negative pixels
    %    'pixelTN'           Number of True  Negative pixels
    %
    % The function returns the precision, accuracy, sensitivity and F1

    pixelPrecision = pixelTP / (pixelTP+pixelFP);
    pixelAccuracy = (pixelTP+pixelTN) / (pixelTP+pixelFP+pixelFN+pixelTN);
    pixelSensitivity = pixelTP / (pixelTP+pixelFN);
	pixelF1 = (2*pixelTP)/(2*pixelTP+pixelFN+pixelFP);
end
