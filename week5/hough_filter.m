function [absolve] = hough_filter (candidate)
dev_thr=10; %threshold in angle degrees

absolve=false;
candidate_edg=edge(candidate);

[H,theta,rho] = hough(candidate_edg);
peaks = houghpeaks(H,4);
lines = houghlines(candidate_edg,theta,rho,peaks);

horizontal_line = [];
vertical_line = [];
obl_line = [];
 for n = 1:length(lines)
     %detect lines orientations
     if((abs(lines(n).theta) >= 90 - dev_thr) && (abs(lines(n).theta) <= 90 + dev_thr))
         horizontal_line = [horizontal_line; [lines(n).point1 lines(n).point2]]; %Horizontal line

     elseif((abs(lines(n).theta) >= 0 - dev_thr) && (abs(lines(n).theta) <= 0 + dev_thr))
         vertical_line = [vertical_line; [lines(n).point1, lines(n).point2]];%Vertical line

     elseif((abs(lines(n).theta) >= 30 - dev_thr) && (abs(lines(n).theta) <= 30 + dev_thr))
         obl_line = [obl_line; [lines(n).point1, lines(n).point2, lines(n).theta]];%oblique

     end
 end

 hor_num = size(horizontal_line,1);
 vert_num = size(vertical_line,1);
 obl_num = size(obl_line,1);

 %square?
 if ((hor_num==2)&&(vert_num==2))
     absolve=true;
 end
 %triangle?
 if ((hor_num>=1)&&(obl_num>=2))
     absolve=true;
 end
 %circle?
 maximum_radius=uint8(ceil(min(length(candidate(:,1))/2,length(candidate(1,:))/2)));
 minimum_radius=uint8(ceil(maximum_radius/2));
 radrange=[minimum_radius,maximum_radius];
 [center,rad] = imfindcircles(logical(candidate), radrange,'Sensitivity',0.96);
 if (~isempty(center))
    absolve=true; 
 end
     
end
