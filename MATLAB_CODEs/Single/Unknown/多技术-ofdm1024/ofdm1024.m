%  MTECH DIGITAL AND INSTRUMENTATION 1ST SEM PROJECT
% BY SHIRSHENDU ROY AND RAHUL DAS
% OFDM SIMULALTION BY MATLAB CODE AND PAPR REDUCTION TECHNIQUE
%
clear all;
close all;
fprintf ('OFDM Analysis Program\n\n');
defaults = input('press any key for entering the parameter value for IFFT_bin_length=1024:\n ');
    IFFT_bin_length =1024
    carrier_count = input('carrier count = ');
    bits_per_symbol = input('bits per symbol = ');
    symbols_per_carrier = input('symbols per carrier =');
    SNR = input('SNR = ');
% Derived parameters
baseband_out_length =  carrier_count * symbols_per_carrier * bits_per_symbol; 
carriers = (1:carrier_count) + (floor(IFFT_bin_length/4) - floor(carrier_count/2));
conjugate_carriers = IFFT_bin_length - carriers + 2;
display(carriers);
display(conjugate_carriers);
% TRANSMIT 
baseband_out = round(rand(1,baseband_out_length));
convert_matrix = reshape(baseband_out, bits_per_symbol, length(baseband_out)/bits_per_symbol);
for k = 1:(length(baseband_out)/bits_per_symbol)
    modulo_baseband(k) = 0;
    for i = 1:bits_per_symbol
        modulo_baseband(k) = modulo_baseband(k) + convert_matrix(i,k)*2^(bits_per_symbol-i);
    end
end

% Serial to Parallel Conversion
carrier_matrix = reshape(modulo_baseband, carrier_count, symbols_per_carrier)';
carrier_matrix = [zeros(1,carrier_count);carrier_matrix];
for i = 2:(symbols_per_carrier + 1)
    carrier_matrix(i,:) = rem(carrier_matrix(i,:)+carrier_matrix(i-1,:),2^bits_per_symbol);
end
% Convert the differential coding into a phase
carrier_matrix = carrier_matrix * ((2*pi)/(2^bits_per_symbol));
% Convert the phase to a complex number
[X,Y] = pol2cart(carrier_matrix, ones(size(carrier_matrix,1),size(carrier_matrix,2)));
complex_carrier_matrix = complex(X,Y);
% Assign each carrier to its IFFT bin
IFFT_modulation = zeros(symbols_per_carrier + 1, IFFT_bin_length);
IFFT_modulation(:,carriers) = complex_carrier_matrix;
IFFT_modulation(:,conjugate_carriers) = conj(complex_carrier_matrix);
ofdm_symbol=IFFT_modulation;
%display(IFFT_modulation)
%z=IFFT_modulation';
%frame_guard1 = [z;zeros(1,carrier_count-1)];
%frame_guard=frame_guard1';
%display(frame_guard);
%
% PLOT BASIC FREQUENCY DOMAIN REPRESENTATION
figure (1)
stem(0:IFFT_bin_length-1, abs(IFFT_modulation(2,1:IFFT_bin_length)),'b*-')
grid on
axis ([0 IFFT_bin_length -0.5 1.5])
ylabel('Magnitude')
xlabel('IFFT Bin')
title('OFDM Carrier Frequency Magnitude')
figure (2)
plot(0:IFFT_bin_length-1, (180/pi)*angle(IFFT_modulation(2,1:IFFT_bin_length)), 'go')
hold on
stem(carriers-1, (180/pi)*angle(IFFT_modulation(2,carriers)),'b*-')
stem(conjugate_carriers-1, (180/pi)*angle(IFFT_modulation(2,conjugate_carriers)),'b*-')
axis ([0 IFFT_bin_length -200 +200])
grid on
ylabel('Phase (degrees)')
xlabel('IFFT Bin')
title('OFDM Carrier Phase')
% Transform each period's spectrum (represented by a row of carriers) to the 
% time domain via IFFT
time_wave_matrix = ifft(IFFT_modulation');
time_wave_matrix = time_wave_matrix';
%ofdm_symbol=time_wave_matrix;
display(time_wave_matrix);
%
% PLOT OFDM SIGNAL FOR ONE SYMBOL PERIOD
figure (3)
plot(0:IFFT_bin_length-1,time_wave_matrix(2,:))
grid on
ylabel('Amplitude')
xlabel('Time')
title('OFDM Time Signal, One Symbol Period')
% Apply a Window Function to each time waveform
for i = 1:symbols_per_carrier + 1
 
    windowed_time_wave_matrix(i,:) = real(time_wave_matrix(i,:));
end
% Serialize the modulating waveform
ofdm_modulation = reshape(windowed_time_wave_matrix', 1, IFFT_bin_length*(symbols_per_carrier+1));
 %PLOT OFDM SIGNAL (time)
temp_time = IFFT_bin_length*(symbols_per_carrier+1);
figure (4)
plot(0:temp_time-1,ofdm_modulation)
grid on
ylabel('Amplitude (volts)')
xlabel('Time (samples)')
title('OFDM Time Signal')
 %PLOT OFDM SIGNAL (spectrum)
symbols_per_average = ceil(symbols_per_carrier/5);
avg_temp_time = IFFT_bin_length*symbols_per_average;
averages = floor(temp_time/avg_temp_time);
average_fft(1:avg_temp_time) = 0;
for a = 0:(averages-1)
    subset_ofdm = ofdm_modulation(((a*avg_temp_time)+1):((a+1)*avg_temp_time));
    subset_ofdm_f = abs(fft(subset_ofdm));
    average_fft = average_fft + (subset_ofdm_f/averages);
end
display(average_fft)
average_fft_log = 20*log10(average_fft);
figure (5)
plot((0:(avg_temp_time-1))/avg_temp_time, average_fft_log)
hold on
plot(0:1/IFFT_bin_length:1, -35, 'rd')
grid on
axis([0 0.5 -40 max(average_fft_log)])
ylabel('Magnitude (dB)')
xlabel('Normalized Frequency (0.5 = fs/2)')
title('OFDM Signal Spectrum')
% Upconversion to RF 
Tx_data = ofdm_modulation;
% CHANNEL 

% The channel model is Gaussian (AWGN) only 
Tx_signal_power = var(Tx_data);
linear_SNR = 10^(SNR/10);
noise_sigma = Tx_signal_power/linear_SNR;
noise_scale_factor = sqrt(noise_sigma);
noise = randn(1, length(Tx_data))*noise_scale_factor;
Rx_Data = Tx_data + noise;
% RECEIVE
% Convert the serial input data stream to parallel (according to symbol length 
Rx_Data_matrix = reshape(Rx_Data, IFFT_bin_length, symbols_per_carrier + 1);
Rx_spectrum = fft(Rx_Data_matrix);%
% PLOT BASIC FREQUENCY DOMAIN REPRESENTATION
figure (6)
stem(0:IFFT_bin_length-1, abs(Rx_spectrum(1:IFFT_bin_length,2)),'b*-')
grid on
axis ([0 IFFT_bin_length -0.5 1.5])
ylabel('Magnitude')
xlabel('FFT Bin')
title('OFDM Receive Spectrum, Magnitude')
figure (7)
plot(0:IFFT_bin_length-1, (180/pi)*angle(Rx_spectrum(1:IFFT_bin_length,2)), 'go')
hold on
stem(carriers-1, (180/pi)*angle(Rx_spectrum(carriers,2)),'b*-')
stem(conjugate_carriers-1, (180/pi)*angle(Rx_spectrum(conjugate_carriers,2)),'b*-')
axis ([0 IFFT_bin_length -200 +200])
grid on
ylabel('Phase (degrees)')
xlabel('FFT Bin')
title('OFDM Receive Spectrum,  Phase')
Rx_carriers = Rx_spectrum(carriers,:)';
% PLOT EACH RECEIVED SYMBOL
figure (8)
Rx_phase_P = angle(Rx_carriers);
Rx_mag_P = abs(Rx_carriers);
polar(Rx_phase_P, Rx_mag_P,'bd');
Rx_phase = angle(Rx_carriers)*(180/pi);
phase_negative = find(Rx_phase < 0);
Rx_phase(phase_negative) = rem(Rx_phase(phase_negative)+360,360);
Rx_decoded_phase = diff(Rx_phase);
phase_negative = find(Rx_decoded_phase < 0);
Rx_decoded_phase(phase_negative) = rem(Rx_decoded_phase(phase_negative)+360,360);
% Convert phase to symbol
base_phase = 360/2^bits_per_symbol;
delta_phase = base_phase/2;
Rx_decoded_symbols = zeros(size(Rx_decoded_phase,1),size(Rx_decoded_phase,2));
for i = 1:(2^bits_per_symbol - 1)  
    center_phase = base_phase*i;
    plus_delta = center_phase+delta_phase;
    minus_delta = center_phase-delta_phase;
    decoded = find((Rx_decoded_phase <= plus_delta) & (Rx_decoded_phase > minus_delta));
    Rx_decoded_symbols(decoded)=i;
end
% Convert the matrix into a serial symbol stream
Rx_serial_symbols = reshape(Rx_decoded_symbols',1,size(Rx_decoded_symbols,1)*size(Rx_decoded_symbols,2));
% Convert the symbols to binary
for i = bits_per_symbol: -1: 1
    if i ~= 1
        Rx_binary_matrix(i,:) = rem(Rx_serial_symbols,2);
        Rx_serial_symbols = floor(Rx_serial_symbols/2);
    else
        Rx_binary_matrix(i,:) = Rx_serial_symbols;
    end
end
baseband_in = reshape(Rx_binary_matrix,1,size(Rx_binary_matrix,1)*size(Rx_binary_matrix,2));
%
% Find bit errors
%
bit_errors = find(baseband_in ~= baseband_out);
bit_error_count = size(bit_errors,2);
%%%%%%%%%%%%%  DIFFERENT PAPR REDUCTION TECHNIQUES %%%%%%%%%%%%%%%
%%%%%%%%%%%%%  AMPLITUDE CLIPING TECHNINQUE %%%%%%%%%%%%%%%
avg=0.05;
for K=1:4
clipped(K,:)=time_wave_matrix(K,:);
for i=1:length(clipped)
if clipped(:,i) > avg
		clipped(:,i) = avg;
    end
    if clipped(:,i) < -avg
		clipped(:,i) = -avg;
    end
end
end
display(clipped)
figure(9)
plot(real(clipped(2,:))); xlabel('Time'); ylabel('Amplitude');
title('clipped Signal');grid on;

    
    % --------------calculate  papr of original ofdm------------
   for i=1:4
     time_domain_signal1=abs(clipped(i,1:1024));
     meano=mean(abs(time_domain_signal1).^2);
     peako=max(abs(time_domain_signal1).^2);
     papr1(i)=10*log10(peako/meano);
   end
figure(10)
subplot(2,2,3);
title('AMP CLIPPING');
%papr=[1 2 3 4 5 6 7 8 9 10 11 13 14 15 16 17 18 19 20 21 22 23]
[N,X] = hist(papr1,100); 
plot(X,1-cumsum(N)/max(cumsum(N)),'-.black', 'LineWidth',2, 'MarkerEdgeColor', 'r', 'MarkerSize',8); 
grid on;
xlabel('papr1....AMP CLIPPING, x dB')
ylabel('ccdf')


%%%%%%%%%%%%%  PARTIAL TRANSMIT SEQUENCE TECHNIQUE %%%%%%%%%%%%%%%

%close all
%clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% All permutations of phase factor B
p=[1 -1 i -i]; % phase factor possible values
B=[];
for b1=1:4
for b2=1:4
for b3=1:4
for b4=1:4
for b5=1:4
B=[B; [p(b1)  p(b2)  p(b3) p(b4)]]; % all possible combinations
end
end
end
end
end
NN=symbols_per_carrier;  % the test is achieved on 10000 OFDM symbols only. It is 
           % possible to use all of the 100000 symbols, but it will
           % take more time.
N=IFFT_bin_length;  % number of subbands
L=4;  % oversampling factor

for i=1:NN
    
    % calculate  papr of original ofdm
     time_domain_signal1=abs(ifft([ofdm_symbol(i,1:512) zeros(1,(L-1)*N) ofdm_symbol(i,513:1024)]));
     meano=mean(abs(time_domain_signal1).^2);
     peako=max(abs(time_domain_signal1).^2);
     papro(i)=10*log10(peako/meano);
   
    % Partition OFDM Symbol
     P1=[ofdm_symbol(i,1:256) zeros(1,768)];
     P2=[zeros(1,256) ofdm_symbol(i,257:512) zeros(1,512)];
     P3=[zeros(1,512) ofdm_symbol(i,513:768) zeros(1,256)];
     P4=[zeros(1,768) ofdm_symbol(i,769:1024)];
     
     % Transform Pi to Time Domain
     Pt1=abs(ifft([P1(1:512) zeros(1,(L-1)*N) P1(513:1024)]));
     Pt2=abs(ifft([P2(1:512) zeros(1,(L-1)*N) P2(513:1024)]));
     Pt3=abs(ifft([P3(1:512) zeros(1,(L-1)*N) P3(513:1024)]));
     Pt4=abs(ifft([P4(1:512) zeros(1,(L-1)*N) P4(513:1024)]));
          
        
    % Combine in Time Domain and find papr_min
    papr2(i)=papro(i);
    for k=1:256 
      final_signal=B(k,1)*Pt1+B(k,2)*Pt2+B(k,3)*Pt3+B(k,4)*Pt4;
      meank=mean(abs(final_signal).^2);
      peak=max(abs(final_signal).^2);
      papr=10*log10(peak/meank);
    
      if papr < papr2(i)
         papr2(i)=papr;
         sig=final_signal;
      end
    end
    
end
subplot(2,2,1);
title('ORIGINAL signal');
[N,X] = hist(papro,100); 
plot(X,1-cumsum(N)/max(cumsum(N)),'-ro', 'LineWidth',2, 'MarkerEdgeColor', 'r', 'MarkerSize',8); 
grid;
xlabel('paprO...original signal, x dB')
ylabel('ccdf')
subplot(2,2,2);
title('PTS');
[N,X] = hist(papr2,100); 
plot(X,1-cumsum(N)/max(cumsum(N)),'-.green', 'LineWidth',2, 'MarkerEdgeColor', 'r', 'MarkerSize',8); 
grid;
xlabel('papr2....PARTIAL TRANSMIT, x dB')
ylabel('ccdf')


%%%%%%%%%%%%%  SELECTIVE MAPPING TECHNIQUE %%%%%%%%%%
N=IFFT_bin_length; 
%L=4;  % oversampling factor
C=4; % number of OFDM symbol candidate
% phase factor matrix [B] generation 
%p=[1 -1 j -j]; % phase factor possible values
%randn('state', 12345);
%B=randsrc(C,N,p); % generate N-point phase factors for each one of the
size(B)
D=B'
%size(ofdn_symbol)
for i=1:NN
      %calculate  papr of original ofdm
     time_domain_signal1=abs(ifft([ofdm_symbol(i,1:512) zeros(1,(L-1)*N) ofdm_symbol(i,513:1024)]));
     meano=mean(abs(time_domain_signal1).^2);
     peako=max(abs(time_domain_signal1).^2);
     papro(i)=10*log10(peako/meano);
    % B*ofdm symbol
    p=[];
    for k=1:C
        p=[p; D(k,:).*ofdm_symbol(i,:)];
    end
     % Transform Pi to Time Domain and find paprs
     for k=1:C
         pt(k,:)=abs(ifft([p(k,1:512) zeros(1,(L-1)*N) p(k,513:1024)]));
         papr(k)=10*log10(max(abs(pt(k,:)).^2)/mean(abs(pt(k,:)).^2));
     end
     
    % find papr_min
    papr_min(i)=min(papr);
end
subplot(2,2,4);
[N,X] = hist(papr_min,100); 
plot(X,1-cumsum(N)/max(cumsum(N)),'-.b', 'LineWidth',2, 'MarkerEdgeColor', 'r', 'MarkerSize',8); 
grid;
xlabel('papr3....SELECTIVE MAPPING, x dB')
ylabel('ccdf=pr(papr>papr0')
%
% plot all the papr reduction technique
%
figure(11)
[N,X] = hist(papro,100); 
plot(X,1-cumsum(N)/max(cumsum(N)),'-ro', 'LineWidth',3, 'MarkerEdgeColor', 'r', 'MarkerSize',8);
axis([4 27 -0.025 0.8]);
hold all
[N,X] = hist(papr_min,100); 
plot(X,1-cumsum(N)/max(cumsum(N)),'blue', 'LineWidth',3, 'MarkerEdgeColor', 'r', 'MarkerSize',8); 
hold all
[N,X] = hist(papr2,100); 
plot(X,1-cumsum(N)/max(cumsum(N)),'green', 'LineWidth',3, 'MarkerEdgeColor', 'r', 'MarkerSize',8);
hold all;
[N,X] = hist(papr1,100); 
plot(X,1-cumsum(N)/max(cumsum(N)),'black', 'LineWidth',3, 'MarkerEdgeColor', 'r', 'MarkerSize',8); 
grid;
hold all;
grid on;
hleg=legend('ORIGINAL','SLM','PTS','CLIPPING');