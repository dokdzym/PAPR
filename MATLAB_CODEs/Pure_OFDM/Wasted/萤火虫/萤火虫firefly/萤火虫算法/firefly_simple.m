% ======================================================== % 
% Files of the Matlab programs included in the book:       %
% Xin-She Yang, Nature-Inspired Metaheuristic Algorithms,  %
% Second Edition, Luniver Press, (2010).   www.luniver.com %
% ======================================================== %    

% Firefly Algorithm by X S Yang (Cambridge University)
% Usage: firefly_simple([number_of_fireflies,MaxGeneration])
%  eg:   firefly_simple([12,50]);
function [best]=firefly_simple(instr)
% n是萤火虫数目
% MaxGeneration=number of pseudo time steps
if nargin<1,   instr=[12 50];     end
n=instr(1);  MaxGeneration=instr(2);
rand('state',0);  % 重置随机发生器
% ------ 4个峰值函数---------------------
str1='exp(-(x-4)^2-(y-4)^2)+exp(-(x+4)^2-(y-4)^2)';
str2='+2*exp(-x^2-(y+4)^2)+2*exp(-x^2-y^2)';
funstr=strcat(str1,str2);
% 转换为内联函数
f=vectorize(inline(funstr));
% range=[xmin xmax ymin ymax];
range=[-5 5 -5 5]; %该函数在下方

% ------------------------------------------------
alpha=0.2;      % 随机度 Randomness 0--1 (highly random)
gamma=4.0;      % 吸收系数 Absorption coefficient 
% ------------------------------------------------
% Grid values are used for display only坐标值只用于显示
Ngrid=100;
dx=(range(2)-range(1))/Ngrid;
dy=(range(4)-range(3))/Ngrid;
[x,y]=meshgrid(range(1):dx:range(2),...
               range(3):dy:range(4));
z=f(x,y);%f在第21行
% 显示目标函数的形状 （三维）Display the shape of the objective function
figure(1);    surfc(x,y,z);

% ------------------------------------------------
% 萤火虫位置初始化
[xn,yn,Lightn]=init_ffa(n,range);
% Display the paths of fireflies in a figure with
% contours of the function to be optimized
% 在图中显示萤火虫的路径以及要优化功能的轮廓
 figure(2);
% Iterations or pseudo time marching 迭代或伪时间行进
for i=1:MaxGeneration,     %%%%% start iterations
% Show the contours of the function
 contour(x,y,z,15); hold on;
% Evaluate new solutions
zn=f(xn,yn);

% Ranking the fireflies by their light intensity
[Lightn,Index]=sort(zn);
xn=xn(Index); yn=yn(Index);
xo=xn;   yo=yn;    Lighto=Lightn;
% Trace the paths of all roaming  fireflies
plot(xn,yn,'.','markersize',10,'markerfacecolor','g');
% Move all fireflies to the better locations
[xn,yn]=ffa_move(xn,yn,Lightn,xo,yo,Lighto,alpha,gamma,range);
drawnow;
% Use "hold on" to show the paths of fireflies
    hold off;
end   %%%%% end of iterations
best(:,1)=xo'; best(:,2)=yo'; best(:,3)=Lighto';

% ----- 所有子函数在此列出 ---------
% n个萤火虫的初始位置
function [xn,yn,Lightn]=init_ffa(n,range)
xrange=range(2)-range(1);
yrange=range(4)-range(3);
xn=rand(1,n)*xrange+range(1);
yn=rand(1,n)*yrange+range(3);
Lightn=zeros(size(yn));

% 所有萤火虫朝着更亮的点移动
function [xn,yn]=ffa_move(xn,yn,Lightn,xo,yo,...
    Lighto,alpha,gamma,range)
ni=size(yn,2); nj=size(yo,2);
for i=1:ni,
% The attractiveness parameter beta=exp(-gamma*r)
    for j=1:nj,
r=sqrt((xn(i)-xo(j))^2+(yn(i)-yo(j))^2);
if Lightn(i)<Lighto(j), % Brighter and more attractive
beta0=1;     beta=beta0*exp(-gamma*r.^2);
xn(i)=xn(i).*(1-beta)+xo(j).*beta+alpha.*(rand-0.5);
yn(i)=yn(i).*(1-beta)+yo(j).*beta+alpha.*(rand-0.5);
end
    end % end for j
end % end for i
[xn,yn]=findrange(xn,yn,range);

% 确保萤火虫在范围内
function [xn,yn]=findrange(xn,yn,range)
for i=1:length(yn),
   if xn(i)<=range(1), xn(i)=range(1); end
   if xn(i)>=range(2), xn(i)=range(2); end
   if yn(i)<=range(3), yn(i)=range(3); end
   if yn(i)>=range(4), yn(i)=range(4); end
end
%  ============== end =====================================
