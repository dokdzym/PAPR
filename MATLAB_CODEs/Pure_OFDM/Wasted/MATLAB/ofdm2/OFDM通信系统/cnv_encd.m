%************************beginning of file*****************************
%cnv_encd.m
%卷积码编码程序
function output=cnv_encd(G,k0,input)
% cnv_encd(G,k0,input),k0 是每一时钟周期输入编码器的 bit 数，
% G 是决定输入序列的生成矩阵，它有 n0 行 L*k0 列 n0 是输出 bit 数，
% 参数 n0 和 L 由生成矩阵 G 导出，L 是约束长度。L 之所以叫约束长度
% 是因为编码器在每一时刻里输出序列不但与当前输入序列有关，
% 而且还与编码器的状态有关，这个状态是由编码器的前(L-1)k0。
% 个输入决定的,通常卷积码表示为(n0,k0,m)，m=(L-1)*k0 是编码
% 器中的编码存贮个数，也就是分为 L-1 段，每段 k0 个
% 有些人将 m=L*k0 定义为约束长度，有的人定义为 m=(L-1)*k0
% 查看是否需要补 0，输入 input 必须是 k0 的整数部

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% G         决定输入序列的生成矩阵
% k0        每一时钟周期输入编码器的 bit 数
% input     输入数据
% output    输入数据
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

if rem(length(input),k0)>0
input=[input,zeros(size(1:k0-rem(length(input),k0)))];
end
n=length(input)/k0;
% 检查生成矩阵 G 的维数是否和 k0 一致
if rem(size(G,2),k0)>0
error('Error,G is not of the right size.')
end
% 得到约束长度 L 和输出比特数 n0
L=size(G,2)/k0;
n0=size(G,1);
% 在信息前后加 0，使存贮器归 0，加 0 个数为(L-1)*k0 个
u=[zeros(size(1:(L-1)*k0)),input,zeros(size(1:(L-1)*k0))];
% 得到 uu 矩阵,它的各列是编码器各个存贮器在各时钟周期的内容
u1=u(L*k0:-1:1);
%将加 0 后的输入序列按每组 L*k0 个分组，分组是按 k0 比特增加
%从 1 到 L*k0 比特为第一组，从 1+k0 到 L*k0+k0 为第二组，。。。。，
%并将分组按倒序排列。
for i=1:n+L-2
u1=[u1,u((i+L)*k0:-1:i*k0+1)];
end
uu=reshape(u1,L*k0,n+L-1);
% 得到输出，输出由生成矩阵 G*uu 得到
output=reshape(rem(G*uu,2),1,n0*(L+n-1));
% ************************end of file***********************************