% Selected Mapping (SLM)is one of the techniques used for
% peak-to-average power ratio (PAPR) reduction in OFDM systems.
% In this .m file it is simulated for a QPSK modulated, 64-subband
% OFDM symbols.
% The CCDF function is called in this .m file. The CCDF function is 
% available for free download at the 'file exchange' web page.
%
% By: Abdulrahman Ikram Siddiq
% Kirkuk - IRAQ
% Sunday Oct.23rd 2011 9:30 PM

clc
clear

load ofdm_100000  % this is a .mat file containing 100000 QPSK modulated,
                  % 64-element OFDM symbols. It is available with the 
                  % partial_transmit_sequence.m file, previously submitted
                  % by the auther, for free download at the 'file exchange'
                  % web page.

NN=10000; % the test is achieved on 10000 OFDM symbols only. It is 
          % possible to use all of the 100000 symbols, but it will
          % take more time.
N=64; % number of subbands
L=4;  % oversampling factor
C=16; % number of OFDM symbol candidates

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% phase factor matrix [B] generation 
p=[1 -1 j -j]; % phase factor possible values
randn('state', 12345);
B=randsrc(C,N,p); % generate N-point phase factors for each one of the 
                  % C OFDM candidates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:NN
     % calculate  papr of original ofdm
     time_domain_signal=abs(ifft([ofdm_symbol(i,1:32) zeros(1,(L-1)*N) ofdm_symbol(i,33:64)]));
     meano=mean(abs(time_domain_signal).^2);
     peako=max(abs(time_domain_signal).^2);
     papro(i)=10*log10(peako/meano);
    
    % B*ofdm symbol
    p=[];
    for k=1:C
        p=[p; B(k,:).*ofdm_symbol(i,:)];
    end
     
     % Transform Pi to Time Domain and find paprs
     for k=1:C
         pt(k,:)=abs(ifft([p(k,1:32) zeros(1,(L-1)*N) p(k,33:64)]));
         papr(k)=10*log10(max(abs(pt(k,:)).^2)/mean(abs(pt(k,:)).^2));
     end
     
    % find papr_min
    papr_min(i)=min(papr);
    end

figure
[cy,cx]=ccdf(papro,0.1);
semilogy(cx,cy) % CCDF of PAPR of the original OFDM
hold on
[cy,cx]=ccdf(papr_min,0.1);
semilogy(cx,cy,'r') % CCDF of the modified OFDM (by SLM)