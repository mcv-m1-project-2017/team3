function [final_windows] = compute_window_candidates(detected_centers, centers_windows, W)

candidate = 1;
w_candidate = zeros(size(detected_centers,1),4);
for i = 1:size(centers_windows,1)
    cont = 0;
    current_window = zeros(sum(centers_windows(i,:)),5);
    for j = 1:size(centers_windows,2)
        if centers_windows(i,j) == 1
            cont = cont + 1;
            h = W(j,2);
            w = W(j,1); 
            x1_c = detected_centers(i,2) - floor(h/2);
            y1_c = detected_centers(i,1) - floor(w/2);
            x2_c = detected_centers(i,2) + floor(h/2);
            y2_c = detected_centers(i,1) + floor(w/2);
            area = h*w;
            current_window(cont,:) = [x1_c, y1_c, x2_c, y2_c, area];
        end
    end
    weights = (current_window(:,5)/sum(current_window(:,5)));
    current_window = current_window(:,1:4);
    result = floor(weights' * current_window);
    w_candidate(candidate,:) = result;
    candidate = candidate + 1;
end

filtered_windows = w_candidate;

number_overlapping_windows = Inf;
while number_overlapping_windows > 0
    final_windows_1 = merge_windows(filtered_windows);
    final_windows = merge_windows(final_windows_1);
    if (size(final_windows_1,1) == size(final_windows,1))
        number_overlapping_windows = 0;
    end
    filtered_windows = final_windows;
end
final_windows = filtered_windows;

end