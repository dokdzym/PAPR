close all
clc
clear all
s = rng(211);       % Set RNG state for repeatability
numFFT = 1024;           % Number of FFT points
numRBs = 50;             % Number of resource blocks
rbSize = 12;             % Number of subcarriers per resource block
cpLen = 72;              % Cyclic prefix length in samples

bitsPerSubCarrier = 4;   % 2: QPSK, 4: 16QAM, 6: 64QAM, 8: 256QAM
snrdB = 18;              % SNR in dB

toneOffset = 2.5;        % Tone offset or excess bandwidth (in subcarriers)
L = 513;                 % Filter length (=filterOrder+1), odd
numDataCarriers = numRBs*rbSize;    % number of data subcarriers in sub-band
halfFilt = floor(L/2);
n = -halfFilt:halfFilt;

% Sinc function prototype filter
pb = sinc((numDataCarriers+2*toneOffset).*n./numFFT);

% Sinc truncation window
w = (0.5*(1+cos(2*pi.*n/(L-1)))).^0.6;

% Normalized lowpass filter coefficients
fnum = (pb.*w)/sum(pb.*w);

% Use dsp filter objects for filtering
filtTx = dsp.FIRFilter('Structure', 'Direct form symmetric', ...
    'Numerator', fnum);
filtRx = clone(filtTx); % Matched filter for the Rx

% QAM Symbol mapper
qamMapper = comm.RectangularQAMModulator( ...
    'ModulationOrder', 2^bitsPerSubCarrier, 'BitInput', true, ...
    'NormalizationMethod', 'Average power');



% Generate data symbols
bitsIn = randi([0 1], bitsPerSubCarrier*numDataCarriers, 1);
symbolsIn = step(qamMapper,bitsIn);
% symbolsIn = qamMapper(bitsIn);

% Pack data into an OFDM symbol
offset = (numFFT-numDataCarriers)/2; % for band center
symbolsInOFDM = [zeros(offset,1); symbolsIn; ...
                 zeros(numFFT-offset-numDataCarriers,1)];
ifftOut = ifft(ifftshift(symbolsInOFDM)); %左右互换

% Prepend cyclic prefix
txSigOFDM = [ifftOut(end-cpLen+1:end); ifftOut];%在1024中将末尾72个放到最前方

% Filter, with zero-padding to flush tail. Get the transmit signal
% txSigFOFDM = [txSigOFDM; zeros(L-1,1)];
% txSigFOFDM = filtTx([txSigOFDM; zeros(L-1,1)]);
figure(100)
txSigOFDM1 =  reshape(repmat(txSigOFDM.',4),[],1);%四倍数据?为什么1097和1对不上
txSigOFDM1 = txSigOFDM1(1:length(txSigOFDM1)/4);
pwelch(txSigOFDM1);
title('un-Filtered spectrum');
txSigFOFDM = step(filtTx,[txSigOFDM; zeros(L-1,1)]);%flitTx的作用？
% txSigFOFDM = [zeros((L-1)/2,1);txSigOFDM;zeros((L-1)/2,1)];
txSigFOFDM1 =  reshape(repmat(txSigFOFDM.',4),[],1);
txSigFOFDM = txSigFOFDM1(1:length(txSigFOFDM1)/4);
figure(1)
pwelch(txSigFOFDM)
title('Base Band specturm');
sps = 4;
t = 0:1:length(txSigFOFDM)-1;
txSig_x = real(txSigFOFDM);
txSig_y = imag(txSigFOFDM);
carrier1_x = cos(2*pi*1*t'/sps);
data_mod1_x = txSig_x.*carrier1_x;
carrier1_y = sin(2*pi*1*t'/sps);
data_mod1_y = txSig_y.*carrier1_y;
mt_x = data_mod1_x + data_mod1_y;
figure(2)
pwelch(mt_x)
title('IF specturm');
% Add WGN
rxSig = awgn(mt_x, snrdB, 'measured');


rxSig_x = rxSig.*carrier1_x;
rxSig_y = rxSig.*carrier1_y;
result = rxSig_x + 1i*rxSig_y;
rxSig = rxSig_x(1:4:end)+1i*rxSig_y(2:4:end);


% Receive matched filter
% rxSigFilt = filtRx(rxSig);
rxSigFilt = step(filtRx,rxSig);

% Account for filter delay
% rxSigFiltSync = rxSigFilt(L:end);
rxSigFiltSync = rxSigFilt(L:end);%滤波器

% Remove cyclic prefix
rxSymbol = rxSigFiltSync(cpLen+1:end);%去除开头的72个保护间隔

% Perform FFT
RxSymbols = fftshift(fft(rxSymbol));

% Select data subcarriers
dataRxSymbols = RxSymbols(offset+(1:numDataCarriers));


scatterplot(dataRxSymbols);


% Channel equalization is not necessary here as no channel is modeled

% Demapping and BER computation
qamDemod = comm.RectangularQAMDemodulator('ModulationOrder', ...
    2^bitsPerSubCarrier, 'BitOutput', true, ...
    'NormalizationMethod', 'Average power');
BER = comm.ErrorRate;

% Perform hard decision and measure errors
% rxBits = qamDemod(dataRxSymbols);
rxBits = step(qamDemod,dataRxSymbols);
% ber = BER(bitsIn, rxBits);
 ber = step(BER, bitsIn, rxBits);
disp(['F-OFDM Reception, BER = ' num2str(ber(1)) ' at SNR = ' ...
    num2str(snrdB) ' dB']);

% Restore RNG state
rng(s);
