function y = bin2pol(x)
% Converts binary numbers (0,1) to polar numbers (-1,1)
% Accepts a 1-D array of binary numbers
y = ones(1,length(x));
for i = 1:length(x)
if x(i) == 0
y(i) = -1;
end
end
