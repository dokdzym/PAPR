% Optiwave Systems (May 2017) Authors: Jianhong Ke, Marc Verreault
% OFDM Receiver (QPSK - 1 user)

SignalIX               = InputPort1.Sampled.Signal;
SignalQX               = InputPort2.Sampled.Signal;

NumberOfIFFTSamples   = 128;
Carrier_location      = [2:41,89:128];
NumberOfCarriers      = length(Carrier_location);
NumberOfGuardTime     = 5;
BitRate               = 40e9;
NumberOfSamples       = 2048*2;
Sample_per_bit        = 2;
NumberOfBitsPerSymbol = 2; %QPSK
   
SymbolRate            = BitRate/NumberOfBitsPerSymbol; %for single pol
ScopeSampleRate       = BitRate/Sample_per_bit;
TimeOS                = InputPort1.Sampled.Time;
TimeEndOS             = TimeOS(end);

zeroPadFactor         = NumberOfIFFTSamples/NumberOfCarriers;
NumberOfBits          = length(TimeOS)/Sample_per_bit; 
NrOfDigitalSymbols    = floor(NumberOfBits/NumberOfBitsPerSymbol);%single pol
NrOfOFDMSymbols       = floor(NrOfDigitalSymbols *zeroPadFactor/(NumberOfIFFTSamples+NumberOfGuardTime)) ;%changed floor to round
% TimeEnd               = NrOfOFDMSymbols *NumberOfBitsPerSymbol * (NumberOfIFFTSamples+NumberOfGuardTime)/ BitRate;

Time1                  = 0:TimeEndOS/(round(NrOfDigitalSymbols*zeroPadFactor)-1):TimeEndOS;

%%  Analog to Digital conversion (ADC)
SignalTimeIX = interp1(TimeOS,SignalIX,Time1,'spline',1e-100);
SignalTimeQX = interp1(TimeOS,SignalQX,Time1,'spline',1e-100);

%% Serial to parallel conversion

SignalTimeIX = SignalTimeIX(1:NrOfOFDMSymbols*(NumberOfIFFTSamples+NumberOfGuardTime));
SignalTimeQX = SignalTimeQX(1:NrOfOFDMSymbols*(NumberOfIFFTSamples+NumberOfGuardTime));

SignalBaseIX = reshape(SignalTimeIX, NumberOfIFFTSamples + NumberOfGuardTime, NrOfOFDMSymbols);
SignalBaseQX = reshape(SignalTimeQX, NumberOfIFFTSamples + NumberOfGuardTime, NrOfOFDMSymbols);

%% Remove cyclic prefix

SignalBaseIX = SignalBaseIX(NumberOfGuardTime + 1 : NumberOfIFFTSamples + NumberOfGuardTime, :);
SignalBaseQX = SignalBaseQX(NumberOfGuardTime + 1 : NumberOfIFFTSamples + NumberOfGuardTime, :);

%% FFT
SpectralIX    = fft(SignalBaseIX);
SpectralQX    = fft(SignalBaseQX);

SpectralIQX = SpectralIX + 1i.*SpectralQX;

%% Carrier location

SpectralrcX   = SpectralIQX';

%%% did fftshift before ifft, need to do fftshift again in the receiver
IQXmatrix = zeros(NrOfOFDMSymbols,NumberOfCarriers);

for i = 1:NrOfOFDMSymbols
    IQXmatrix(i , :)                     = SpectralrcX(i , Carrier_location);
end

%% Normalization

IQX = reshape(IQXmatrix,1,size(IQXmatrix,1)*size(IQXmatrix,2));

NormFactor = 1; %For QPSK

[IX QX]= OFDM_Normalization(real(IQX),imag(IQX),NormFactor );

IQX = IX + 1i.*QX;

IQXmatrix = reshape(IQX,NrOfOFDMSymbols,NumberOfCarriers);

IQX = reshape(IQXmatrix,1,size(IQXmatrix,1)*size(IQXmatrix,2));

QAMSymbols = [1+1i, 1-1i, -1+1i, -1-1i];

%% Decision

load('C:\Users\zym\Desktop\PAPR\OFDM\Simu\OFDMMATLAB\InputMary_I')
load('C:\Users\zym\Desktop\PAPR\OFDM\Simu\OFDMMATLAB\InputMary_Q')

OutputPort1 = InputPort1;
OutputPort2 = InputPort2;

SymbolsI = InputPort1.Sequence;
SymbolsQ = InputPort2.Sequence;

% Ideal symbols
SymbolsX = SymbolsI + 1i.*SymbolsQ;

% Make the decision
IQXresult = zeros(1,length(IQX));
for k = 1:length(IQX) 
    IQXresult(k) = decision(IQX(k),QAMSymbols);
end

for k = 1:length(SymbolsX)
    SymbolsX(k) = decision(SymbolsX(k),QAMSymbols);
end

NumSampVals = length(IQXresult);  
PRBSconcat_X = [SymbolsX SymbolsX];

seq_len = length(PRBSconcat_X);
SampValX = [IQXresult zeros(1,seq_len-NumSampVals)];
  
CorrX1 = ifft(fft(PRBSconcat_X) .* conj(fft(SampValX )));
CorrX = real(CorrX1);

% Find out the delay for x pol
shiftX = find(CorrX == max(CorrX)) - 1;

% Align the samples and the symbols
PRBSconcatshift_X = [PRBSconcat_X(1+shiftX(1):seq_len),PRBSconcat_X(1:shiftX(1))];
SampX = SampValX(1:NumSampVals);
SymbolsX = PRBSconcatshift_X(1:NumSampVals);

SampX     = circshift(SampX',shiftX)';

% Allocate recovered symbols to output ports (1-I and 2-Q)
OutputPort1.Sequence = real(SampX);
OutputPort2.Sequence = imag(SampX);  
    
