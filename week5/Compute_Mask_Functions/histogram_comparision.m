function [final_mask] = histogram_comparision(mask, im, Cb_sig, Cr_sig, hue_sig)

% INPUT: 'mask' input mask to be filtered
%        'im' input image of the corresponding mask
%        
% OUTPUT:'final_mask' resulting mask after histogram comparision filtering 

labels = bwlabel(mask);
            for s=1:max(max(labels))
                labels_tmp = labels;
                labels_tmp(labels~=s)=0;
                labels_tmp(labels_tmp==s)=1;
                sig_detected = uint8(labels_tmp).*im;
                sig_detected_HSV = rgb2hsv(sig_detected);
    %             sig_detected_YCbCr = rgb2ycbcr(sig_detected);
                H_sig_detected = sig_detected_HSV(:,:,1);
    %             Cb_sig_detected = sig_detected_YCbCr(:,:,2);
    %             Cr_sig_detected = sig_detected_YCbCr(:,:,3);
                %figure(); imshow(sig_detected);
                %subplot(1,3,1);
                if max(any(H_sig_detected))
                    figure();
                    hist_target_hue = histogram(H_sig_detected(H_sig_detected~=0),100);
                    hist_target_hue.BinCounts = hist_target_hue.BinCounts/length(hist_target_hue.Data);
        %             subplot(1,3,2); hist_target_Cb = histogram(Cb_sig_detected(Cb_sig_detected~=0),100);
        %             hist_target_Cb.BinCounts = hist_target_Cb.BinCounts/length(hist_target_Cb.Data);
        %             subplot(1,3,3); hist_target_Cr = histogram(Cr_sig_detected(Cr_sig_detected~=0),100);
        %             hist_target_Cr.BinCounts = hist_target_Cr.BinCounts/length(hist_target_Cr.Data);
                    for h=1:6
                        match_values_H(h) = compare_histograms(hist_target_hue, hue_sig{h});
        %                 match_values_Cb(h) = compare_histograms(hist_target_Cb, Cb_sig{h});
        %                 match_values_Cr(h) = compare_histograms(hist_target_Cr, Cr_sig{h});
                    end
                    close(figure(7));
                    if match_values_H(:)<0.5
                        if match_values_H(4)<0.24 & match_values_H(6)<0.18
                            labels(labels==s)=0;
                        end
                    end
                end
            end
            labels(labels~=0)=1;
    %         figure();
    %         subplot(1,2,1); imshow(final_mask);
            final_mask = labels;
    %         subplot(1,2,2); imshow(final_mask);
end