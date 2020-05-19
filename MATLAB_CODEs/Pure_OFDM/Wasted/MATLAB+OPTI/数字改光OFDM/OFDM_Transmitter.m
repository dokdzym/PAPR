% Optiwave Systems (May 2017) Authors: Jianhong Ke, Marc Verreault
% OFDM Transmitter model (QPSK - 1 user)

% Read in symbol data from input ports
IX = InputPort1.Sequence;
QX = InputPort2.Sequence;
IQX = IX + 1i .* QX;

% OFDM Tx parameters
NumberOfIFFTSamples   = 128;
Carrier_location      = [2:41,89:128];
NumberOfCarriers      = length(Carrier_location);
NumberOfGuardTime     = 5;
NumberOfSamples       = 2048*2;
SampleRate            = 40e9;

zeroPadFactor       = NumberOfIFFTSamples/NumberOfCarriers;
% Number of M_ary symbols
NrOfDigitalSymbols  = length(IQX); 
% Number of OFDM symbols that can be entirely transmitted in the time window
NrOfOFDMSymbols     = floor(NrOfDigitalSymbols*zeroPadFactor/(NumberOfIFFTSamples+NumberOfGuardTime)); 
% OptiSystem time window
TimeEndOS           = NrOfDigitalSymbols/InputPort1.BitRate;                     

IQXmatrix = reshape(IQX(1:NrOfOFDMSymbols*NumberOfCarriers),NrOfOFDMSymbols,NumberOfCarriers );
  
% IFFT
% Zero-padding for IFFT
Spectral            = zeros( NrOfOFDMSymbols , NumberOfIFFTSamples);

for i = 1:NrOfOFDMSymbols
    Spectral(i,Carrier_location)     = IQXmatrix(i,:);
end

SignalBaseI    = real(ifft(Spectral'));
SignalBaseQ    = imag(ifft(Spectral'));

% Cyclic prefix
A = SignalBaseI( NumberOfIFFTSamples - NumberOfGuardTime + 1 : NumberOfIFFTSamples , : );
B = SignalBaseQ( NumberOfIFFTSamples - NumberOfGuardTime + 1 : NumberOfIFFTSamples , : );

TimeSignalPlusGuardI = [A ; SignalBaseI];
TimeSignalPlusGuardQ = [B ; SignalBaseQ];

%%% Interpolation
SignalTimeI = reshape(TimeSignalPlusGuardI, 1, size(TimeSignalPlusGuardI,1)*size(TimeSignalPlusGuardQ,2));
SignalTimeQ = reshape(TimeSignalPlusGuardQ, 1, size(TimeSignalPlusGuardQ,1)*size(TimeSignalPlusGuardQ,2));


SignalTimeI = [SignalTimeI, SignalTimeI ];
SignalTimeI = SignalTimeI(1:round(NrOfDigitalSymbols*zeroPadFactor));
SignalTimeQ = [SignalTimeQ, SignalTimeQ ];
SignalTimeQ = SignalTimeQ(1:round(NrOfDigitalSymbols*zeroPadFactor));


TimeO1   = 0:TimeEndOS/(length(SignalTimeI)-1):TimeEndOS;
TimeOS   = 0:TimeEndOS/(NumberOfSamples-1):TimeEndOS;

% Digital to analog conversion (DAC)
SignalI = interp1(TimeO1,SignalTimeI,TimeOS,'spline',1e-100);
SignalQ = interp1(TimeO1,SignalTimeQ,TimeOS,'spline',1e-100);

% Create frequency grid
% deltaf1 = SampleRate/NumberOfSamples;
% freqO = [0 : (NumberOfSamples /2 - 1), (-NumberOfSamples /2) : (-1)] * deltaf1;
% 
% figure
% plot(freqO, 10*log10(real(fft(SignalI)).^2), '-r')
% pause(10);

%%% Create output structures that will be loaded into OptiSystem

OutputPort1.TypeSignal           = 'Electrical';
OutputPort1.Noise                = [];
OutputPort1.IndividualSample     = [];
OutputPort1.Sampled.Signal       = SignalI;
OutputPort1.Sampled.Time         = TimeOS;

OutputPort2.TypeSignal           = 'Electrical';
OutputPort2.Noise                = [];
OutputPort2.IndividualSample     = [];
OutputPort2.Sampled.Signal       = SignalQ;
OutputPort2.Sampled.Time         = TimeOS;

clear TimeO TimeOS SignalI SignalQ Spectra Y SymbolMatrix SymbolVector NumberOfSymbolsPerCar TimeEnd A B TimeSignalPlusGuardI TimeSignalPlusGuardQ SignalTimeI SignalTimeQ SignalBaseI SignalBaseQ
clear A B BitSequence BitsTransmitted Carriers NegCarriers NrOfDigitalSymbols NrOfDigitalSymbols TimeEndOS Spectral M NumberOfBitsTx NrOfOFDMSymbols NumberOfBitsPerSymbol NumberOfSamples InputPort1
clear NumberOfGuardTime NumberOfCarriers NumberOfIFFTSamples