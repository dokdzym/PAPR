% Partial Transmit Sequence is one of the effective techniques for
% peak-to-average power ratio (PAPR) reduction in OFDM systems.
% In this .m file it is simulated for a QPSK modulated, 64-subband
% OFDM symbols.

close all
clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% All permutations of phase factor B
p=[1 -1 j -j]; % phase factor possible values
B=[];
for b1=1:4
for b2=1:4
for b3=1:4
for b4=1:4
B=[B; [p(b1)  p(b2)  p(b3) p(b4)]]; % all possible combinations
end
end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load ofdm_100000  % this is a .mat file contaaining 100000 QPSK modulated,
                  % 64-element OFDM symbols. It is available for free
                  % download at the 'file exchange' web page.

NN=1000;  % the test is achieved on 10000 OFDM symbols only. It is 
           % possible to use all of the 100000 symbols, but it will
           % take more time.
N=64;  % number of subbands
L=4;  % oversampling factor


for i=1:NN
    
    % calculate  papr of original ofdm
     time_domain_signal=abs(ifft([ofdm_symbol(i,1:32) zeros(1,(L-1)*N) ofdm_symbol(i,33:64)]));
     meano=mean(abs(time_domain_signal).^2);
     peako=max(abs(time_domain_signal).^2);
     papro(i)=10*log10(peako/meano);
   
    % Partition OFDM Symbol
     P1=[ofdm_symbol(i,1:16) zeros(1,48)];
     P2=[zeros(1,16) ofdm_symbol(i,17:32) zeros(1,32)];
     P3=[zeros(1,32) ofdm_symbol(i,33:48) zeros(1,16)];
     P4=[zeros(1,48) ofdm_symbol(i,49:64)];
     
     % Transform Pi to Time Domain
     Pt1=abs(ifft([P1(1:32) zeros(1,(L-1)*N) P1(33:64)]));
     Pt2=abs(ifft([P2(1:32) zeros(1,(L-1)*N) P2(33:64)]));
     Pt3=abs(ifft([P3(1:32) zeros(1,(L-1)*N) P3(33:64)]));
     Pt4=abs(ifft([P4(1:32) zeros(1,(L-1)*N) P4(33:64)]));
          
        
    % Combine in Time Domain and find papr_min
    papr_min(i)=papro(i);
    for k=1:256 % 256 is the number of possible phase factor combinations
      final_signal=B(k,1)*Pt1+B(k,2)*Pt2+B(k,3)*Pt3+B(k,4)*Pt4;
      meank=mean(abs(final_signal).^2);
      peak=max(abs(final_signal).^2);
      papr=10*log10(peak/meank);
    
      if papr < papr_min(i)
         papr_min(i)=papr;
         sig=final_signal;
      end
    end
    
end

% plot the CCDF of original and pts systems
% N.B. the CCDF function is available for free download at the 'file 
% exchange' web page.
[cy,cx]=ccdf(papro,0.1);
semilogy(cx,cy)
hold on
[cy,cx]=ccdf(papr_min,0.1);
semilogy(cx,cy,'r')


