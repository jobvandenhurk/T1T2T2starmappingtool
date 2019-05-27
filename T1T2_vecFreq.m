function vecFreq = T1T2_vecFreq(input)
% counts occurance of each unique element in input vector
input = input(:);
uniqueItems = unique(input);
vecFreq = zeros(numel(uniqueItems),2);
vecFreq(:,1) = uniqueItems;
for i = 1:numel(uniqueItems)
    vecFreq(i,2) = sum(input == uniqueItems(i));
end