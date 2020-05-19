% IEEE 802.11/a
% OFDM symbol generator
% N=64
% 48 data tones
% 4 pilots
% 12 unused tones
clear
N=64;

unused=zeros(1,12);
pilot=ones(1,4);

s=[-1-j  -1+j  1-j  1+j]; % QPSK
randn('state', 12345);

for i=1:100000  % generate 100000 OFDM symbols

data=s(randsrc(1,48,1:4));
ofdm_symbol(i,:)=[data(1:10) pilot(1) data(11:20) pilot(2) data(21:30) pilot(3) data(31:40) pilot(4) data(41:48) unused];
end
save ofdm_100000 ofdm_symbol