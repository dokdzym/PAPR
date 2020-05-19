function [EstimatedSymbol] = decision(RxSignalSample,QAMSymbols)

% calculates the the minimum Euclidian distance of the received signal
% sample from the symbols of the rectangular QAM grid, expressed in
% a complex array QAMSymbols and returns an estimated symbol

EuclideanDistance = abs(RxSignalSample-QAMSymbols);
[MinDistance MinIndex] = min(EuclideanDistance);
EstimatedSymbol = QAMSymbols(MinIndex);
 
