function [pPrecision, pAccuracy, pF1, pRecall, pTN, pFN, pTP, pFP] = evaluate_mask(guess,truth)
      
% INPUT: 'guess' mask created with color segmentation
%        'truth' ground-truth mask
%  

% OUTPUT: 'pPrecision' precision in terms of pixels (value between 0 and 1)
%         'pAccuracy' accuracy in terms of pixels (value between 0 and 1)
%         'pF1' F1-score in terms of pixels (value between 0 and 1)
%         'pRecall' recall in terms of pixels (value between 0 and 1)
%         'pTN' number of True Negatives in terms of pixels
%         'pFN' number of False Negatives in terms of pixels
%         'pTP' number of True Positives in terms of pixels
%         'pFP' number of False Positives in terms of pixels
%   

    % subtract generated mask to ground truth to find the differences
    % each number represents a diferent case
    error = double(truth) - 2.*double(guess);
    pTN=numel(error(error==0));  % 0 was classified as 0 --> TN
    pFN=numel(error(error==1));  % 1 was classified as 0 --> FN
    pTP=numel(error(error==-1)); % 1 was classified as 1 --> TP
    pFP=numel(error(error==-2)); % 0 was classified as 1 --> FP
    
    % calculate performance measures
    pPrecision = pTP / (pTP+pFP);
    pAccuracy = (pTP+pTN) / (pTP+pFP+pFN+pTN);
    pF1 = 2*(pTP)/(2*pTP+pFN+pFP);
    pRecall = pTP / (pTP+pFN);
end