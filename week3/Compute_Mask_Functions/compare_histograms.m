function match_value = compare_histograms(hist_target, hist_model)

num_bins = hist_target.NumBins;
sumatori = 0;
for i = 1:num_bins
    sumatori = sumatori + min(hist_target.BinCounts(i), hist_model(i));
end

match_value = sumatori;%/length(hist_model.Data);

end