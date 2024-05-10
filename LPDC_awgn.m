clear;
clc;

NumRound = 1e4; % 测试数据的数量
snr_dB = -1 : 0.2 : 1;% snr_dB
ber = zeros(size(snr_dB));% 使用ldpc编码的误码率


% 创建LDPC编码的基矩阵

% B = [10	-1 141	108	3	-1	122	98
%     -1	11 99	142	-1	4	40	123
%     3	96 124	-1	12	97	5	-1
%     39	4  -1	125	97	13	-1	6	];

B = [133	-1	886	647	32	-1	221	912
-1	134	913	887	-1	33	832	222
32	607	223	-1	135	608	34	-1
831	33	-1	224	608	136	-1	35];

blockSize = 947-1;
pcmatrix = ldpcQuasiCyclicMatrix(blockSize,B);
% 创建LDPC编码器和解码器
cfgLDPCEnc = ldpcEncoderConfig(pcmatrix);
cfgLDPCDec = ldpcDecoderConfig(pcmatrix);
% 得到H矩阵
Hmatrix = double(full(pcmatrix));
[M,N] = size(Hmatrix);

% 增加噪声信息
parfor i = 1:length(snr_dB)
    tic
    % 原始数据
    data = randi([0 1],M,NumRound);
    % 对原始数据ldpc编码
    encData = ldpcEncode(data, cfgLDPCEnc);
    % 调制
    txData = pskmod(encData,2,pi);
    % 添加AWGN噪声
    noisyData = awgn(txData,snr_dB(i),'measured');
    % 解调
    rxData = pskdemod(noisyData,2,pi,OutputType='llr');
    % 解码ldpc码字
    decData = ldpcDecode(rxData,cfgLDPCDec,50);
    % 计算误码率
    [~,ber(i)] = biterr(data,double(decData));
    toc
end

% ber2 = berawgn(snr_dB, 'psk', 2, 'nondiff');

semilogy(snr_dB+4.5,ber,'*-b','LineWidth',1.25);
hold on 
% semilogy(snr_dB,ber2,'x-r','LineWidth',1.25);
hold off
xlabel('EbN0(dB)');
axis([0 6 1e-7 1e0]);
ylabel('ber');
grid on