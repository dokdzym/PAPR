%************************beginning of file*****************************
%viterbi.m
%viterbi 解码程序
% function [decoder_output,survivor_state,cumulated_metric]=viterbi(G,k,channel_output)
function  decoder_output=viterbi(G,k,channel_output)
% [decoder_output,survivor_state,cumulated_metric]=viterbi(G,k,channel_output)
% 其中 G 是一个 n 行 L*k 列矩阵，它的每一行决定了从移位寄存器到输入码字的连接方式.
% survivor_state 是一个矩阵，它显示了通过网格的最优路径，这个矩阵通过一个单独
% 的函数 metric(x,y)给出。

n=size(G,1);
%检验 G 的维数
if rem(size(G,2),k)~=0
error('Size of G and k do not agree')
end
if rem(size(channel_output,2),n)~=0
error('channle output not of the right size')
end
L=size(G,2)/k;
number_of_states=2^((L-1)*k);
%产生状态转移矩阵，输出矩阵和输入矩阵
for j=0:number_of_states-1
for t=0:2^k-1
[next_state,memory_contents]=nxt_stat(j,t,L,k);
input(j+1,next_state+1)=t;
branch_output=rem(memory_contents*G',2);
nextstate(j+1,t+1)=next_state;
output(j+1,t+1)=bin2deci(branch_output);
end
end
input;
state_metric=zeros(number_of_states,2);
depth_of_trellis=length(channel_output)/n;
channel_output_matrix=reshape(channel_output,n,depth_of_trellis);
survivor_state=zeros(number_of_states,depth_of_trellis+1);
[row_survivor col_survivor]=size(survivor_state);
%开始非尾信道输出的解码
%i 为段，j 为每一阶段的状态，t 为输入
for i=1:depth_of_trellis-L+1
flag=zeros(1,number_of_states);
if i<=L
step=2^((L-i)*k);
else
step=1;
end
for j=0:step:number_of_states-1
for t=0:2^k-1
branch_metric=0;
binary_output=deci2bin(output(j+1,t+1),n);
for tt=1:n
branch_metric=branch_metric+metric(channel_output_matrix(tt,i),binary_output(tt));
end
if ((state_metric(nextstate(j+1,t+1)+1,2)>state_metric(j+1,1)+branch_metric)|flag(nextstate(j+1,t+1)+1)==0)
state_metric(nextstate(j+1,t+1)+1,2)=state_metric(j+1,1)+branch_metric;
survivor_state(nextstate(j+1,t+1)+1,i+1)=j;
flag(nextstate(j+1,t+1)+1)=1;
end
end
end
state_metric=state_metric(:,2:-1:1);
end
%开始尾信道输出的解码
for i=depth_of_trellis-L+2:depth_of_trellis
flag=zeros(1,number_of_states);
last_stop=number_of_states/(2^((i-depth_of_trellis+L-2)*k));
for j=0:last_stop-1
branch_metric=0;
binary_output=deci2bin(output(j+1,1),n);
for tt=1:n
branch_metric=branch_metric+metric(channel_output_matrix(tt,i),binary_output(tt));
end
if ((state_metric(nextstate(j+1,1)+1,2)>state_metric(j+1,1)+branch_metric)|flag(nextstate(j+1,1)+1)==0)
state_metric(nextstate(j+1,1)+1,2)=state_metric(j+1,1)+branch_metric;
survivor_state(nextstate(j+1,1)+1,i+1)=j;
flag(nextstate(j+1,1)+1)=1;
end
end
state_metric=state_metric(:,2:-1:1);
end
%从最优路径产生解码输出
%由段得到状态序列，再由状序列从 input 矩阵中得到该段的输出
state_sequence=zeros(1,depth_of_trellis+1);
size(state_sequence);
state_sequence(1,depth_of_trellis)=survivor_state(1,depth_of_trellis+1);
for i=1:depth_of_trellis
state_sequence(1,depth_of_trellis-i+1)=survivor_state((state_sequence(1,depth_of_trellis+2-i)+1),depth_of_trellis-i+2);
end
state_sequence;
decoder_output_matrix=zeros(k,depth_of_trellis-L+1);
for i=1:depth_of_trellis-L+1
dec_output_deci=input(state_sequence(1,i)+1,state_sequence(1,i+1)+1);
dec_output_bin=deci2bin(dec_output_deci,k);
decoder_output_matrix(:,i)=dec_output_bin(k:-1:1)';
end
decoder_output=reshape(decoder_output_matrix,1,k*(depth_of_trellis-L+1));
cumulated_metric=state_metric(1,1);
% ************************end of file***********************************