clear
clc

bgn = 1;     % LDPC base graph number (1 or 2)
nrows = 22;  % number of rows in the base graph
nlift = 128; % lifting factor 
nbitsIn = nrows*nlift;  % number of input bits
maxNumIters = 8;        % max number of LDPC decode iterations
M = 2;                  % modulate order
bitsPerSym = 1;

% SNR values to test
EbN0Test = (0:0.25:3)';
ntest = length(EbN0Test);

% TODO:  Estimate BLER at each Eb/N0
%   bler = ...
bler = zeros(ntest,1);
ber = zeros(ntest,1);
for i = 1:ntest
    EbN0 = EbN0Test(i);
    nerr = 0;
    nblk = 0;
    nerrbit = 0;

    tic;
    while  true
        
        
        % Generate random bits
        bitsIn = randi([0,1], nbitsIn, 1);
        
        % Convolutionally encode the data
        bitsEnc = nrLDPCEncode(bitsIn,bgn);
               
        % QAM modulate
        txSig = pskmod(bitsEnc,M,'InputType','bit');         
        
        % Add noise 
        rate = nbitsIn/length(bitsEnc);
        Es = mean(abs(txSig).^2);
        EsN0 = EbN0 + 10*log10(rate*bitsPerSym);
        chan = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (Es/No)', ...
            'EsNo', EsN0, 'SignalPower', Es);        
        rxSig = chan.step(txSig);
        
        % Compute LLRs
        noiseVar = Es*db2pow(-EsN0);
        llr = pskdemod(rxSig,M,'OutputType','approxllr', ...
            'NoiseVariance', noiseVar);        
       
        % Run Viterbi decoder
        maxNumIters = 8;
        bitsOut = nrLDPCDecode(llr, bgn, maxNumIters);
        bitsOut = bitsOut(1:nbitsIn);
        
        % Compute number of bit errors and add to the total
        if any(bitsIn ~= bitsOut)
            nerr = nerr + 1;
            nerrbit = nerrbit + length(find(bitsIn~=bitsOut));
        end
        nblk = nblk + 1;

        if nerr >= 4 && nblk >= 1e3
            break;
        end 

        
    end
    time = toc;

    % Print results
    bler(i) = nerr / nblk;
    ber(i) = nerrbit / (nblk*nbitsIn);
    fprintf(1, 'EbN0 = %7.2f BLER=%12.4e BER=%12.4e\n', EbN0, bler(i),ber(i));
    disp(['所花费的时间：', num2str(time), ' 秒',num2str(nblk)]);
    if nerr == 0
        break;
    end
end