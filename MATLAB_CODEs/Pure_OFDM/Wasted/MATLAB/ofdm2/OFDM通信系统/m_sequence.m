%************************beginning of file*****************************
%m_sequence.m
%用线性移位寄存器产生m序列

function [mseq]= m_sequence(fbconnection);

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% fbconnection   线性移位寄存器的系数
% mseq           生成的m序列
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

n = length(fbconnection);
N = 2^n-1;
register = [zeros(1,n - 1) 1];%定义移位寄存器的初始状态
mseq(1)= register(n);
for i = 2:N
    newregister(1)= mod(sum(fbconnection.*register),2);
    for j = 2:n,
        newregister(j)= register(j-1);
    end;
    register = newregister;
    mseq(i) = register(n);
end
% ************************end of file**********************************
