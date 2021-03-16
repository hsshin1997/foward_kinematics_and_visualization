%% Filter Data
function Filtered = FilterData(Unfiltered, tol)
    FilterIdx = abs(Unfiltered) <= tol;
    Filtered = Unfiltered;
    Filtered(FilterIdx) = 0;
end