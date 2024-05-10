% Parameters
bitsPerSym = 4; % 4=16-QAM
nsym = 10000;

% TODO
%    ber = ...

% Create random bits to test
nbits = nsym*bitsPerSym;
bits = randi([0,1], nbits, 1);

% Modulate to M-QAM
M = 2^bitsPerSym;
s = qammod(bits,M,'UnitAveragePower', true, 'Input', 'bit');

% SNR levels to test
EsN0Test = (0:30)';
nsnr = length(EsN0Test);
Es = mean(abs(s).^2);

% Fading types to test
fadeTest = [false, true];
nfade = length(fadeTest);

% Initialize vectors
ber = zeros(nsnr,nfade);

% Loop 
for ifade = 1:nfade
    fade = fadeTest(ifade);
    
    for i = 1:nsnr
        % Generate fading channel
        if fade
            h = sqrt(1/2)*(randn(nsym,1) + 1i*randn(nsym,1));
        else
            h = ones(nsym,1);
        end
        rxSig0 = s.*h;
                
        % Add the noise
        EsN0 = EsN0Test(i);
        chan = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (Es/No)',...
            'EsNo', EsN0, 'SignalPower', Es);
        rxSig = chan.step(rxSig0);
        
        % Equalize
        z = rxSig ./ h;
        
        % Demodulate
        bitsEst = qamdemod(z,M,'UnitAveragePower',true,'Output','bit');
        
        % Measure the BER
        EbN0 = EsN0-3;
        ber(i,ifade) = mean(bitsEst ~= bits);
        fprintf(1, 'fading=%d EbN0=%7.2f BER=%12.4e\n', fade, EbN0, ber(i,ifade));
        
        % Break if zero since higher SNRs also be zero
        if (ber(i,ifade) == 0)
            break
        end
    end
end