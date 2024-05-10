clear;
clc;

NumRound = 1e3; % 测试数据的数量
snr_dB = linspace(-1,1,5);% snr_dB
ber = zeros(size(snr_dB));% 使用ldpc编码的误码率


% 创建LDPC编码的基矩阵
P = [
 17 13  8 21  9  3 18 12 10  0  4 15 19  2  5 10 26 19 13 13  1  0 -1 -1
  3 12 11 14 11 25  5 18  0  9  2 26 26 10 24  7 14 20  4  2 -1  0  0 -1
 22 16  4  3 10 21 12  5 21 14 19  5 -1  8  5 18 11  5  5 15  0 -1  0  0
  7  7 14 14  4 16 16 24 24 10  1  7 15  6 10 26  8 18 21 14  1 -1 -1  0
 ];
blockSize = 27;
pcmatrix = ldpcQuasiCyclicMatrix(blockSize,P);
% 创建LDPC编码器和解码器
cfgLDPCEnc = ldpcEncoderConfig(pcmatrix);
cfgLDPCDec = ldpcDecoderConfig(pcmatrix);

% 增加噪声信息
for i = 1:length(snr_dB)
    % 原始数据
    data = randi([0 1],cfgLDPCEnc.NumInformationBits,NumRound);
    % 对原始数据ldpc编码
    encData = ldpcEncode(data, cfgLDPCEnc);
    % 调制
    txData = pskmod(encData,2,pi);
    % 添加AWGN噪声
    noisyData = awgn(txData,snr_dB(i)+3,'measured');
    % 解调
    rxData = pskdemod(noisyData,2,pi,OutputType='llr');
    % 解码ldpc码字
    decData = ldpcDecode(rxData,cfgLDPCDec,10);
    % 计算误码率
    [~,ber(i)] = biterr(data,double(decData));
end

ber2 = berawgn(snr_dB, 'psk', 2, 'nondiff');

semilogy(snr_dB,ber,'*-b','LineWidth',1.25);
hold on 
semilogy(snr_dB,ber2,'x-r','LineWidth',1.25);
xlabel('EbN0(dB)');
ylabel('ber');
grid on