clear 
clc


P = 73; %使用素数373
M = 1;

row = 4;
col = 12;

GF = gftuple([-1 : P^M-2]', M, P);
%构建一个GF域的table，方便进行运算，如果M=1的时候，则没有什么必要
%使用函数gfprimdf可以找到本源多项式，并基于此构造gftuple

%使用两个GF域上的元祖相加可以得到LDPC码，参见
S_1 = GF(2:end);
S_2 = GF(2:end);

eta = 1;

B_q_Sp = zeros(P-1,P-1);

num = P-1;%循环次数
parfor i = 1 : num
    for j = 1 : num
        B_q_Sp(i,j) = gfadd(i-1,j-1,GF);
    end
end

Bm = B_q_Sp(1:row,1:col);

% Mask = [1 0 1 0 1 1 1 1;...
%         0 1 0 1 1 1 1 1;...
%         1 1 1 1 1 0 1 0;...
%         1 1 1 1 0 1 0 1];
Mask = [1 0 1 0 1 1 1 1 1 0 1 0;...
        0 1 0 1 1 1 1 1 0 1 0 1;...
        1 1 1 1 1 0 1 0 1 1 1 1;...
        1 1 1 1 0 1 0 1 1 1 1 1];

for i = 1 : row
    for j = 1 :col
        if Mask(i,j) == 0
            BM_Mask(i,j) = -1;
        else
            BM_Mask(i,j) = Bm(i,j);
        end
    end
end

% B = [10	-1 141	108	3	-1	122	98
%     -1	11 99	142	-1	4	40	123
%     3	96 124	-1	12	97	5	-1
%     39	4  -1	125	97	13	-1	6	];

% 生成H矩阵

% BM_Mask = [BM_Mask(:,1:2) BM_Mask(:,7:8) BM_Mask(:,3:6)]; % 更换顺序以满足N-K满秩的要求
BM_Mask = [BM_Mask(:,1:2) BM_Mask(:,7:12) BM_Mask(:,3:6)]; % 更换顺序以满足N-K满秩的要求

blockSize = P;
pcmatrix = ldpcQuasiCyclicMatrix(blockSize - 1,BM_Mask);
% 创建LDPC编码器和解码器
cfgLDPCEnc = ldpcEncoderConfig(pcmatrix);
cfgLDPCDec = ldpcDecoderConfig(pcmatrix);

% 储存生成的数据
save('Savedata/output.mat','pcmatrix','cfgLDPCDec','cfgLDPCEnc');
disp('LDPC码构造已完成！')

