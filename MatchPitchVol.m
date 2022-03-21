clear all

StandVol = .1; % low volume for the 8kHz tone
CompStartVol = .5;  % middle volume so that the 4kHz doesn't hurt too much
inc = .2; % percent that volume of second sound increases or decreases by. Might want to try something between .1 and .5
test = 1;
resp = [];
fin = [];
StandFreq = 8000;

fail1='Program aborted. Participant number not entered'; % error message which is printed to command window
prompt = {'Enter participant number:'};
dlg_title = 'New Participant';
num_lines = 1;
def = {'0'};
answer = inputdlg(prompt,dlg_title,num_lines,def); % presents box to enter data into
switch isempty(answer)
    case 1 % deals with both cancel and X presses
        error(fail1)
    case 0
        ID=(answer{1});
end

% start the log file for reporting
logFID = fopen([ID '_MatchPitchVol.txt'],'at+'); % open a file as log file for everything (APPEND DATA)

% HideCursor;	% Uncomment to hide the mouse cursor
ListenChar(0);

[windowPr,rect] = Screen('OpenWindow',0,0,[0 0 1920/2,1080/2]); % add a '%' to the beginning of the line to comment out for full screen
% [windowPr,rect] = Screen('OpenWindow',0,0,[]); % uncomment this for full screen
width=rect(RectRight)-rect(RectLeft);
height=rect(RectBottom)-rect(RectTop);

white = WhiteIndex(windowPr);
black = BlackIndex(windowPr);
gray = 97; 
[xCenter, yCenter] = RectCenter(rect);

% fixation cross coords
H=width/2; 
H1=width/2-(width/2/70);
H2=width/2+(width/2/70);
V=height/2;
V1=height/2-(width/2/70);
V2=height/2+(width/2/70);
penWidth=2;
textsize=40;
Font='Arial'; Screen('TextSize',windowPr,textsize); Screen('TextFont',windowPr,Font); Screen('TextColor',windowPr,black);

Screen('FillRect',windowPr,127.5,rect); 
DrawFormattedText(windowPr, 'You will hear two sounds. Your goal is to adjust the volume', 'center', (rect(4)/8)*2);
DrawFormattedText(windowPr, 'so that they are both audible but neither are too loud.', 'center', (rect(4)/8)*3);
DrawFormattedText(windowPr, 'To hear the sounds again, press the space bar.', 'center', (rect(4)/8)*4);
DrawFormattedText(windowPr, 'When the volume is right for you, press the "enter" key.', 'center', (rect(4)/8)*5);
DrawFormattedText(windowPr, 'Press the space bar to continue.', 'center', (rect(4)/8)*6);
Screen('Flip', windowPr); 
WaitSecs(.1);
KbWait;

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
pad = zeros(1,500);

toneFreq = [500 1000 2000 4000];  %# Tone frequency, in Hertz

Stand = (sin(2*pi*StandFreq*t_beep)).*StandVol;
Stand = (1+0.5.*[sin(2*pi*bump(1)*t_beep)]).*Stand;
mid = ones(1,length(Stand) - length(rampUp) - length(rampDown));
envelope = [rampUp mid rampDown];
Stand = [pad (Stand.*envelope) pad];

Low = (sin(2*pi*toneFreq(1)*t_beep)).*CompStartVol;
Low = (1+0.5.*[sin(2*pi*bump(1)*t_beep)]).*Low;
mid = ones(1,length(Low) - length(rampUp) - length(rampDown));
envelope = [rampUp mid rampDown];
Low = [pad (Low.*envelope) pad];

Screen('FillRect',windowPr,127.5,rect); 
Screen('Flip', windowPr); 

prac = 1;

while prac==1
    sound(Stand, Fs);                        
    WaitSecs(2);
    
    sound(Low, Fs);
    WaitSecs(1);
    
    Screen('FillRect',windowPr,127.5,rect); 
    DrawFormattedText(windowPr, 'Please adjust the volume', 'center', (rect(4)/8)*3);   
    DrawFormattedText(windowPr, 'To hear the sounds again, press the space bar.', 'center', (rect(4)/8)*4);
    DrawFormattedText(windowPr, 'When the volume is right for you, press the "enter" key.', 'center', (rect(4)/8)*5);
    Screen('Flip', windowPr); 
    WaitSecs(.1);
    
    KbWait;   
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    naming = sort(KbName(keyCode)) 
    if strmatch('enrrtu',naming) % finished
        prac = 0;
        Screen('FillRect',windowPr,127.5,rect);
        DrawFormattedText(windowPr, 'We are about to start the study.', 'center', (rect(4)/8)*3);
        DrawFormattedText(windowPr, 'Please do not adjust the volume from now on.', 'center', (rect(4)/8)*4);
        DrawFormattedText(windowPr, 'Please wait. The screen will adjust.', 'center', (rect(4)/8)*5);
        Screen('Flip', windowPr); 
        WaitSecs(5); 
    elseif strmatch('aceps',naming)
        prac = 1;
    else
        Screen('FillRect',windowPr,127.5,rect);
        DrawFormattedText(windowPr, 'Did you press the wrong key?', 'center', (rect(4)/8)*4);
        DrawFormattedText(windowPr, 'Restarting the trial.', 'center', (rect(4)/8)*5);
        Screen('Flip', windowPr); 
        WaitSecs(1);        
    end
end   

Screen('CloseAll');

%%%%%%%% Main study %%%%%%%%%%%%%

[windowPr,rect] = Screen('OpenWindow',0,0,[]);%0 0 1920/2,1080/2]);
width=rect(RectRight)-rect(RectLeft);
height=rect(RectBottom)-rect(RectTop);

white = WhiteIndex(windowPr);
black = BlackIndex(windowPr);
gray = 97; 
[xCenter, yCenter] = RectCenter(rect);

% fixation cross coords
H=width/2; 
H1=width/2-(width/2/70);
H2=width/2+(width/2/70);
V=height/2;
V1=height/2-(width/2/70);
V2=height/2+(width/2/70);
penWidth=2;
textsize=40;
Font='Arial'; Screen('TextSize',windowPr,textsize); Screen('TextFont',windowPr,Font); Screen('TextColor',windowPr,black);

Screen('FillRect',windowPr,127.5,rect); 
DrawFormattedText(windowPr, 'You will hear two sounds. The aim is to get the two sounds the same volume.', 'center', (rect(4)/8)*2);
DrawFormattedText(windowPr, 'If the second sound is quieter than the first, press the "up" arrow to increase the volume.', 'center', (rect(4)/8)*3);
DrawFormattedText(windowPr, 'If the second sound is louder, press the "down" arrow to decrease the volume.', 'center', (rect(4)/8)*4);
DrawFormattedText(windowPr, 'When the sounds are the same volume, press the "enter" key.', 'center', (rect(4)/8)*5);
DrawFormattedText(windowPr, 'Press the space bar to continue.', 'center', (rect(4)/8)*6);
Screen('Flip', windowPr); 
WaitSecs(.1);
KbWait;

Screen('FillRect',windowPr,127.5,rect); 
Screen('Flip', windowPr); 

for j = 1:3
    toneperm = toneFreq(randperm(length(toneFreq)));
    for i = 1:length(toneperm)
        test = 1; 
        CompVol = CompStartVol;
        while test==1
            sound(Stand, Fs);                        
            WaitSecs(2);
            
            Comp = (sin(2*pi*toneperm(i)*t_beep)).*CompVol;
            Comp = (1+0.5.*[sin(2*pi*bump(1)*t_beep)]).*Comp;
            mid = ones(1,length(Comp) - length(rampUp) - length(rampDown));
            envelope = [rampUp mid rampDown];
            Comp = [pad (Comp.*envelope) pad];
            sound(Comp, Fs);
            WaitSecs(1);
    
            Screen('FillRect',windowPr,127.5,rect); 
            DrawFormattedText(windowPr, 'If the second sound is quieter , press the "up" arrow to increase the volume.', 'center', (rect(4)/8)*3);
            DrawFormattedText(windowPr, 'If the second sound is louder, press the "down" arrow to decrease the volume.', 'center', (rect(4)/8)*4);
            DrawFormattedText(windowPr, 'When the sounds are the same volume, press the "enter" key.', 'center', (rect(4)/8)*5);   
            Screen('Flip', windowPr); 
            WaitSecs(.1);
    
            KbWait;   
            [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
            naming = sort(KbName(keyCode)) 
            if strmatch('dnow',naming) % need volume to go down        
                CompVol = CompVol-inc;
                key = -1;
                if CompVol<0
                    CompVol = 0;
                end
            elseif strmatch('pu',naming) % need volume to go up
                CompVol = CompVol+inc;
                key = 1;
                if CompVol>1
                    CompVol = 1;
                end
            elseif strmatch('enrrtu',naming) % finished
                test = 0;
                key = 0;
                toneperm(i)
                endVol = CompVol
                f = size(fin,2);
                fin(1,f+1) = toneperm(i);
                fin(2,f+1) = endVol;
            elseif strmatch('ces',naming) 
                Screen('CloseAll');
                xlswrite([ID '_MatchPitchVol.xlsx'], resp, 1);
                xlswrite([ID '_MatchPitchVol.xlsx'], fin, 2);
                fclose(logFID);
                pTaba = pivottable(fin',[],1,2,@mean)
                xlswrite([ID '_MatchPitchVol.xlsx'], pTaba, 3);
            else
                Screen('FillRect',windowPr,127.5,rect); 
                DrawFormattedText(windowPr, 'Did you press the wrong key?', 'center', (rect(4)/8)*4);
                DrawFormattedText(windowPr, 'Restarting the trial.', 'center', (rect(4)/8)*5);
                Screen('Flip', windowPr); 
                WaitSecs(1);
                key = 2; 
            end
            
            Screen('FillRect',windowPr,127.5,rect); 
            Screen('Flip', windowPr); 
            WaitSecs(.5);
            
            sz = size(resp,2);
            resp(1,sz+1) = toneperm(i);
            resp(2,sz+1) = CompVol; 
            resp(3,sz+1) = StandFreq;
            resp(4,sz+1) = StandVol;
            resp(5,sz+1 ) = key;
            
            % print to logfile:
            fprintf(logFID,['%d\t%d\t%d\t%d\t%d\t\n']', toneperm(i), CompVol, StandFreq, StandVol, key);
                    
            clearvars key
        end
    end
end

Screen('CloseAll');
ListenChar(1);

pTaba = pivottable(fin',[],1,2,@mean)
xlswrite([ID '_MatchPitchVol.xlsx'], resp, 1);
xlswrite([ID '_MatchPitchVol.xlsx'], fin, 2);
xlswrite([ID '_MatchPitchVol.xlsx'], pTaba, 3);
fclose(logFID);
