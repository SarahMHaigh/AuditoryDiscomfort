clear all
% Screen('Preference', 'SkipSyncTests', 1);

Vol500 = .876;
Vol1000 = .875;
Vol2000 = .38;
Vol4000 = .55;
Vol8000 = .1; % leave alone

resp = [];

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
logFID = fopen([ID '_AMdisc.txt'],'at+'); % open a file as log file for everything (APPEND DATA)

% HideCursor;	% Hide the mouse cursor

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
DrawFormattedText(windowPr, 'You will be presented with sounds one at a time.', 'center', (rect(4)/8)*2);
DrawFormattedText(windowPr, 'Please rate them on how uncomfortable they are to listen to.', 'center', (rect(4)/8)*3);
DrawFormattedText(windowPr, 'Use the top keyboard. 1=less uncomfortable. 9=very uncomfortable.', 'center', (rect(4)/8)*4);
DrawFormattedText(windowPr, 'If the sounds are too uncomfortable, please let the experimenter know.', 'center', (rect(4)/8)*5);
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

% cosine ramp
A=(0:dt:Tattack)/Tattack;
Tfade=(pi/(length(A)-.5));
RaisedCosine=cos(pi:Tfade:3*pi)+1;
RaisedCosineNormSquare=(RaisedCosine/max(RaisedCosine)).^2;
A=RaisedCosineNormSquare(1:(length(RaisedCosineNormSquare)/2));
rampUp = A;
rampDown = fliplr(rampUp);
pad = zeros(1,500);

tones = {[500,0,Vol500] [1000,0,Vol1000] [2000,0,Vol2000] [4000,0,Vol4000] [8000,0,Vol8000]...
    [500,2,Vol500] [1000,2,Vol1000] [2000,2,Vol2000] [4000,2,Vol4000] [8000,2,Vol8000]...
    [500,4,Vol500] [1000,4,Vol1000] [2000,4,Vol2000] [4000,4,Vol4000] [8000,4,Vol8000]...
    [500,8,Vol500] [1000,8,Vol1000] [2000,8,Vol2000] [4000,8,Vol4000] [8000,8,Vol8000]...
    [500,16,Vol500] [1000,16,Vol1000] [2000,16,Vol2000] [4000,16,Vol4000] [8000,16,Vol8000]...
    [500,32,Vol500] [1000,32,Vol1000] [2000,32,Vol2000] [4000,32,Vol4000] [8000,32,Vol8000]};  %# Tone frequency, in Hertz

Screen('FillRect',windowPr,127.5,rect); 
Screen('Flip', windowPr); 

clearvars KbWait

for j = 1:3
    toneperm = tones(randperm(length(tones)));
    for i = 1:length(tones)
        bump = (sin(2*pi*toneperm{i}(1)*t_beep)).*toneperm{i}(3);
        bump = (1+0.5.*[sin(2*pi*toneperm{i}(2)*t_beep)]).*bump;
        mid = ones(1,length(bump) - length(rampUp) - length(rampDown));
        envelope = [rampUp mid rampDown];
        bump = [pad (bump.*envelope) pad];
        sound(bump, Fs);        
        
        Screen('FillRect',windowPr,127.5,rect);        
        DrawFormattedText(windowPr, 'Please rate the sound on how uncomfortable it is to listen to.', 'center', (rect(4)/8)*3);
        DrawFormattedText(windowPr, 'Use the top keyboard. 1=less uncomfortable. 9=very uncomfortable.', 'center', (rect(4)/8)*4); 123        
        Screen('Flip', windowPr); 
        WaitSecs(1);
        KbWait;

        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        naming = sort(KbName(keyCode))
        if naming(2)=='1'
            x = 1;
        elseif naming(1)=='2'
            x = 2;
        elseif naming(2)=='3'
            x = 3;
        elseif naming(2)=='4'
            x = 4;
        elseif naming(2)=='5'
            x = 5;
        elseif naming(1)=='6'
            x = 6;
        elseif naming(2)=='7'
            x = 7;
        elseif naming(2)=='8'
            x = 8;
        elseif naming(2)=='9'
            x = 9;
        elseif strmatch('ces',naming)
            Screen('CloseAll');
            xlswrite([ID '_AMdisc.xlsx'], resp);
            fclose(logFID);
        else
            Screen('FillRect',windowPr,127.5,rect);
            DrawFormattedText(windowPr, 'Did you press the wrong key?', 'center', (rect(4)/8)*4);
            Screen('Flip', windowPr); 
            WaitSecs(1);
            x = 10;
        end
        
        naming
        x
        WaitSecs(.1); 
        
        Screen('FillRect',windowPr,127.5,rect); 
        Screen('Flip', windowPr);
        WaitSecs(1); 
        
        sz = size(resp,2);
        resp(1,sz+1) = toneperm{i}(1);
        resp(2,sz+1) = toneperm{i}(2);
        resp(3,sz+1) = toneperm{i}(3);
        resp(4,sz+1) = x;
        
        % print to logfile:
        fprintf(logFID,['%d\t%d\t%d\t%d\t\n']', toneperm{i}(1), toneperm{i}(2), toneperm{i}(3), x);
        
        clearvars x naming
    end
end

Screen('CloseAll');
xlswrite([ID '_AMdisc.xlsx'], resp);
fclose(logFID);