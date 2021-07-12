%% Experiment 1
% Creates amplitude modulated pure tones. Checks for perceived loudness and adjusts

clear all

% Specs for the tone
Fs = 44100;      %# Samples per second
dt = 1/Fs;
nSeconds = 1;   %# Duration of the sound
t_beep = [dt:dt:nSeconds];
Tattack = 0.05; 
bump = [0 2 4 8 16 32];

% cosine ramp
A=(0:dt:Tattack)/Tattack;
Tfade=(pi/(length(A)-.5));
RaisedCosine=cos(pi:Tfade:3*pi)+1;
RaisedCosineNormSquare=(RaisedCosine/max(RaisedCosine)).^2;
A=RaisedCosineNormSquare(1:(length(RaisedCosineNormSquare)/2));
rampUp = A;
rampDown = fliplr(rampUp);
pad = zeros(1,50);

toneFreq = [250 500 1000 1500 2000 3000 4000 6000 8000];  %# Tone frequency, in Hertz
for i = 1:length(toneFreq)
    yT = [sin(2*pi*toneFreq(i)*t_beep)];
    maxVol = ones(1,length(yT));
    VolN = yT.*(maxVol*0.5);

    for j = 1:length(bump)
        modul = (1+0.5.*[sin(2*pi*bump(j)*t_beep)]).*VolN;
        mid = ones(1,length(modul) - length(rampUp) - length(rampDown));
        envelope = [rampUp mid rampDown];
        shapedVol = modul.*envelope;
        presentVol = [pad shapedVol pad];
        sound(presentVol, Fs);
        figure;plot(presentVol);
        WaitSecs(1.5);
        audiowrite([num2str(toneFreq(i)/1000) 'kHz_' num2str(bump(j)) 'Hz_orig.wav'], presentVol, Fs);
        x = audioread([num2str(toneFreq(i)/1000) 'kHz_' num2str(bump(j)) 'Hz_orig.wav']);
        l(j,i) = acousticLoudness(x, Fs); %  returns loudness in sones according to ISO 532-1 (Zwicker).
        c = 1-((l(j,i)-30)*2/100);
        presentVol = presentVol.*c;
        audiowrite([num2str(toneFreq(i)/1000) 'kHz_' num2str(bump(j)) 'Hz.wav'], presentVol, Fs);
        x = audioread([num2str(toneFreq(i)/1000) 'kHz_' num2str(bump(j)) 'Hz.wav']);
        lo(j,i) = acousticLoudness(x, Fs)
    end
end

%% Experiment 2
% Frequency modulated tones

Fs = 44100;                                             % Samples per second (resolution)
d = 1/Fs;                                               % Converted samples per second
f = 5:5:50;                                             % Repetition frequency (starts at 5Hz and goes up in increments of 5 to 50Hz)

% Create vol ramp up and ramp down to avoid the speakers clicking
Tattack = 0.005;                                        % Ramp duration
A=(0:d:Tattack)/Tattack;
Tfade=(pi/(length(A)-.5));
RaisedCosine=cos(pi:Tfade:3*pi)+1;
RaisedCosineNormSquare=(RaisedCosine/max(RaisedCosine)).^2;
A=RaisedCosineNormSquare(1:(length(RaisedCosineNormSquare)/2));
rampUp = A;
rampDown = fliplr(rampUp);

for i=1:length(f)                                       % Do the same as above except add the ramp to avoid speaker clicking
    dur = 1/f(i);
    t=0:d:dur;                                          % # secs @ Fs sample rate
    y=chirp(t,500,dur,2000);                            % T,F0,T1,F1 - generates samples of a linear swept-frequency signal at the time instances defined in array T. The instantaneous frequency at time 0 is F0 Hertz. The instantaneous frequency F1 is achieved at time T1.
%     figure;spectrogram(y,256,250,256);                % Display the spectrogram
    mid = ones(1,length(y) - length(rampUp) - length(rampDown)); % Create a vector that is the same length as the tone
    envelope = [rampUp mid rampDown];                   % Add the ramp up and ramp down
    shapedVol = y.*envelope;
    
    x = repmat(shapedVol,1,f(i));
    figure;spectrogram(x,256,250,256);
    sound(x, Fs);
    audiowrite(['FM_' num2str(f(i)) 'Hz.wav'],x,Fs);    % Saves the audio to a wav file
    WaitSecs(1.2);
    clearvars dur t y x
end

%% Experiment 3
% 5Hz FM between 500-2000Hz

Fs = 44100;                                             % Samples per second (resolution)
d = 1/Fs;                                               % Converted samples per second
f = 5;                                                  % Repetition frequency (starts at 5Hz and goes up in increments of 5 to 50Hz)
low = 500:125:1200;
high = 2000:-125:1300;

% Create vol ramp up and ramp down to avoid the speakers clicking
Tattack = 0.005;                                        % Ramp duration
A=(0:d:Tattack)/Tattack;
Tfade=(pi/(length(A)-.5));
RaisedCosine=cos(pi:Tfade:3*pi)+1;
RaisedCosineNormSquare=(RaisedCosine/max(RaisedCosine)).^2;
A=RaisedCosineNormSquare(1:(length(RaisedCosineNormSquare)/2));
rampUp = A;
rampDown = fliplr(rampUp);

for i=1:length(high)                                       % Do the same as above except add the ramp to avoid speaker clicking
    dur = 1/f;
    t=0:d:dur;                                          % # secs @ Fs sample rate
    y=chirp(t,low(i),dur,high(i));                            % T,F0,T1,F1 - generates samples of a linear swept-frequency signal at the time instances defined in array T. The instantaneous frequency at time 0 is F0 Hertz. The instantaneous frequency F1 is achieved at time T1.
%     figure;spectrogram(y,256,250,256);                % Display the spectrogram
    mid = ones(1,length(y) - length(rampUp) - length(rampDown)); % Create a vector that is the same length as the tone
    envelope = [rampUp mid rampDown];                   % Add the ramp up and ramp down
    shapedVol = y.*envelope;
    
    x = repmat(shapedVol,1,f);
    figure;spectrogram(x,256,250,256);
    sound(x, Fs);
    audiowrite(['FM_' num2str(low(i)) '_' num2str(high(i)) '_Mean_Hz.wav'],x,Fs);    % Saves the audio to a wav file
    WaitSecs(1.2);
    clearvars dur t y x
end
