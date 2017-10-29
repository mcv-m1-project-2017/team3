function output_windows = merge_windows(coordinates)
    
    output_windows = zeros(size(coordinates));    
    cont = 0;
    for i = 1:size(coordinates,1)
        
        ntimes_this_w_was_detected = 0;
        current_window = []; 
        x1A = coordinates(i,1);
        y1A = coordinates(i,2);
        x2A = coordinates(i,3);
        y2A = coordinates(i,4);
        
        if (x1A~=0 && y1A~=0 && x2A~=0 && y2A~=0)
            cont = cont + 1; 
            x1_max = Inf; x2_max = -Inf; y1_max = Inf; y2_max = -Inf;
            
            for j = 1:size(coordinates,1)

                    x1B = coordinates(j,1);
                    y1B = coordinates(j,2);
                    x2B = coordinates(j,3);
                    y2B = coordinates(j,4);         
                    
                    if (x1B~=0 && y1B~=0 && x2B~=0 && y2B~=0)
                        if (x1A<=x2B && x2A>=x1B && y1A<=y2B && y2A>=y1B) % overlap condition
                            ntimes_this_w_was_detected = ntimes_this_w_was_detected + 1;
                            if x1B < x1_max
                                x1_max = x1B;
                            end
                            if y1B < y1_max
                                y1_max = y1B; 
                            end
                            if x2B > x2_max
                                x2_max = x2B;
                            end
                            if y2B > y2_max
                                y2_max = y2B;
                            end
                            current_window =  [current_window; x1B, y1B, x2B, y2B];
                            coordinates(j,:) = 0;
                        end
                    end
            end
            avg_window = floor(sum(current_window,1)/size(current_window,1));
            max_window = floor([x1_max y1_max x2_max y2_max]);
            output_windows(cont,:) = floor(avg_window/2 + max_window/2); 
        end
    end
    
    output_windows = output_windows(any(output_windows,2),:);
    
end