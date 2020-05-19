function y1=A_qpsk()
clear all;
close all;
clc;
data=input('Enter the data values');
N=length(data);
fprintf('length of data='),disp(N);
for i=1:N                                                                  %  Loop for generation of bipolar data
if(data(i)==0)
    data(i)= -1;
end;
end;

 for i=1:N/2                                                               % Loop for separating even and odd space placed data
     odd(i)=data(2*i-1);
     even(i)=data(2*i);
 end;
 
 if(mod(N,2)~=0)                                                           % Condition for handling odd number of data inputs
 odd((N+1)/2)=data(N); 
 end;
 
fprintf('bipolar data='),disp(data),fprintf('odd='),disp(odd),
fprintf('even='),disp(even);

 if(mod(N,2)~=0)                                                           % Condition for handling odd number of data inputs
 even((N+1)/2)=0; 
 end;
 
Ts=0.001;                                                                  % The sampling time
T=0.5;                                                                     % Period Duration
t=(0:Ts:T)';

basiscos=cos(8*pi*t/T);                                                    % The sin basis function for odd
modOut1=basiscos*odd;                                                      % The modulated out

modOut1=reshape(modOut1,1,length(t)*length(odd));

t=(0:Ts:T)';
basissin=sin(8*pi*t/T);                                                    % The cos basis function for even
modOut2=basissin*even;                                                     % The modulated out
modOut2=reshape(modOut2,1,length(t)*length(even));
modOut=modOut1+modOut2;
subplot(2,1,1),stem(odd),title('Odd sequence data');
subplot(2,1,2),stem(even),title('Even sequence data');
figure;
subplot(3,1,1),plot(modOut1),title('Odd sequence modulated cosine waveform'),xlabel('Time (in msec.)'),xlim([0 ceil(N/2)*500]);
subplot(3,1,2),plot(modOut2),title('Even sequence modulated sine waveform'),xlabel('Time (in msec.)'),xlim([0 ceil(N/2)*500]);
subplot(3,1,3),plot(modOut),title('QPSK waveform'),xlabel('Time (in msec.)'),xlim([0 ceil(N/2)*500]);