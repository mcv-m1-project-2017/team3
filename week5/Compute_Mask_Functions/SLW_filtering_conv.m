function [final_mask, WindowCandidates] = SLW_filtering_conv(original_mask, features)

max_h = ceil(max(features.height.max)); min_h = floor(min(features.width.min));
aspect_ratios = [0.4 0.7 1 1.2 1.4]; % from form factor
n_scales = 7; % how many different h to use between min_h and max_h ?
sides = round(linspace(min_h, max_h, n_scales));
sides(~mod(sides,2)) =  sides(~mod(sides,2)) + 1;
feat_fill = features.filling_ratio;

dev_thr = 0.005;
original_mask = double(original_mask);
[detected_centers(:,1),detected_centers(:,2)] = find(original_mask >= 0);
number_windows = length(sides)*length(aspect_ratios);
centers_windows = zeros(size(detected_centers,1),number_windows);
W = zeros(number_windows,2);
current_window = 0;

for h = sides
    for a = aspect_ratios
        w = floor(a*h);
        if (mod(w,2) == 0), w = w + 1; end
        wind = ones(h,w);
        fill_mat = conv2(original_mask,wind,'same'); 
        fill_mat = fill_mat/(h*w);
        mask_centers = (fill_mat < feat_fill.mean(1) + dev_thr & fill_mat > feat_fill.mean(1) - dev_thr) | ...
                       (fill_mat < feat_fill.mean(2) + dev_thr & fill_mat > feat_fill.mean(2) - dev_thr) | ...
                       (fill_mat < feat_fill.mean(3) + dev_thr & fill_mat > feat_fill.mean(3) - dev_thr) | ...
                       (fill_mat < feat_fill.mean(4) + dev_thr & fill_mat > feat_fill.mean(4) - dev_thr) | ...
                       (fill_mat < feat_fill.mean(5) + dev_thr & fill_mat > feat_fill.mean(5) - dev_thr) | ...
                       (fill_mat < feat_fill.mean(6) + dev_thr & fill_mat > feat_fill.mean(6) - dev_thr);
        current_window = current_window+1;
        centers_windows(find(mask_centers),current_window) = 1;
        W(current_window,:) = [w, h];
    end
end
tmp = any(centers_windows,2);
centers_windows = centers_windows(tmp,:);
detected_centers = detected_centers(tmp,:);

final_windows = compute_window_candidates(detected_centers, centers_windows, W);

% set everything outside the windows to 0 in the final mask
final_mask = zeros(size(original_mask));
for k = 1:size(final_windows,1)
    [max_row, max_col] = size(original_mask);
    if final_windows(k,1) >= 0, x1 = final_windows(k,1); else, x1 = 1; end
    if final_windows(k,2) >= 0, y1 = final_windows(k,2); else, y1 = 1; end
    if final_windows(k,3) <= max_col, x2 = final_windows(k,3); else, x2 = max_col; end
    if final_windows(k,4) <= max_row, y2 = final_windows(k,4); else, y2 = max_row; end
    final_windows(k,:) = [x1, y1, x2, y2];
    final_mask(y1:y2,x1:x2) = original_mask(y1:y2,x1:x2);
end

% compute window candidates
WindowCandidates = [];
for j = 1:size(final_windows,1)
    x = final_windows(j,1);
    y = final_windows(j,2);
    w = final_windows(j,3) - x;
    h = final_windows(j,4) - y;
    bbox_signal = struct('x',x,'y',y,'w',w,'h',h);
    WindowCandidates = [WindowCandidates, bbox_signal]; 
end

end