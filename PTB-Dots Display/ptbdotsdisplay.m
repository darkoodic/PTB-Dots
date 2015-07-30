% PTB-Dots Display (GitHub Version)
% Darko Odic (http://odic.psych.ubc.ca)
% University of British Columbia

% Last Update: July/30/2015
% Please read README.md before using. 

% You must have images in the /InputImages/ folder for this code to run.
% You can generate images using the ptbdotsgen scripts.
function [] = ptbdotsdisplay()
    HideCursor;
    clear all;
    warning off;
    rand('twister',sum(100*clock));
    AssertOpenGL;
    InitializePsychSound;
    KbName('UnifyKeyNames');
    
    %% OPEN CONFIG FILE
    inputFile = fopen('config.txt');
    inputCells = textscan(inputFile,'%s\t %s\n');
  
    %% OPEN SCREEN
    % Note that both debug being on and off turns off Sync Tests (due to Mac issues)
    % If it doesn't cause problems on your machine, I would turn Sync Tests back on. 
    if(strcmp(inputCells{2}{strcmp('debug',inputCells{1})},'on'))
        ListenChar(0);
        sub = input('Subject number:   ', 's');
        isi = str2num(inputCells{2}{strcmp('isi',inputCells{1})});    
        Screen('Preference','SkipSyncTests',1);
        [w,rect]=Screen('OpenWindow',max(Screen('screens')),[127 127 127],[0 0 800 600]);
    else
        prompt = {'Subject Number:', 'ISI'};
        defaults = {'999', inputCells{2}{strcmp('isi',inputCells{1})}};
        answer = inputdlg(prompt, 'PTB-Dots Display', 1, defaults);
        [sub, isi] = deal(answer{:});
        isi = str2num(isi);
        Screen('Preference','SkipSyncTests',1);
        [w,rect]=Screen('OpenWindow',max(Screen('screens')),[127 127 127]);
        ListenChar(2);
    end
    Screen('TextFont', w, 'Helvetica');
    Screen('TextSize', w, 24);
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    key1 = inputCells{2}{strcmp('key1',inputCells{1})};
    key2 = inputCells{2}{strcmp('key2',inputCells{1})};

    %% MAKE DATA FILE  
    fn = strcat('Data/PTBDotsDisplay', '_', datestr(now, 'mmdd'),'_', sub,'.xls');

    fid = fopen(fn, 'a+');
    sub = str2num(sub); %#ok<ST2NM>
    fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\n', ...
        'SubNum',...
        'TrialNum',...
        'TimeStamp',...
        'ISI',...
        'ImageNum',...
        'ImageShown',...
        'Number1',...
        'Number2',...
        'Ratio',...
        'Area1',...
        'Area2',...
        'AreaCongruency',...
        'KeyPressed',...
        'RT',...
        'Correct');
    fclose(fid);

    inputFile = fopen('config.txt');
    inputCells = textscan(inputFile,'%s\t %s\n');

    %% LOAD IN IMAGE LIST
    % This list structure here tightly depends on the outputs of the
    % ptbdotsgen script. If you alter that script (or use your own images)
    % please make sure you revise the structure accordingly. For a list of
    % columns read in, see comments below.
    % Note that the total number of trials is the number of images, and no
    % image is allowed to repeat (this could be altered). 
    imageFile = fopen('InputImages/imageStats.txt');
    trialArray=textscan(imageFile,'%d\t %d\t %s\t %s\t %s\t %d\t %d\t %f\t %f\t %f\t %d\n', 'Headerlines',1);
    %trialArray{:,1} imageNumbers
    %trialArray{:,2} didIt
    %trialArray{:,3} imageNames (need to append folder and .png)
    %trialArray{:,4} color1string
    %trialArray{:,5} color2string
    %trialArray{:,6} trialNumber1
    %trialArray{:,7} trialNumber2
    %trialArray{:,8} ratio
    %trialArray{:,9} area1
    %trialArray{:,10} area2
    %trialArray{:,11} areaCongruency
    trialOrder = randperm(length(trialArray{:,1})); %shuffle trials
    
     %TRIAL ARRAY
    if(sub == str2num(inputCells{2}{strcmp('pracSN',inputCells{1})}))
        totalTrials = 5;
    end
   
    %% SHOW INSTRUCTIONS
    % To make your own, go to the /Instructions/ folder, edit the Powerpoint file and save as image. 
    if(strcmp(inputCells{2}{strcmp('debug',inputCells{1})},'off'))
        imageID = strcat('Instructions/instructions1.png'); 
        [im , ~, ~] = imread(imageID);
        picIndex = Screen('MakeTexture', w, im);             
        [y,x,~] = size(im); %get size of image
        Screen('DrawTexture', w, picIndex, [0 0 x y], rect);   
        Screen('Flip',w);
        RestrictKeysForKbCheck([KbName('c')]); %hard-coded for participant to not quickly advance
        KbWait();

        imageID = strcat('Instructions/instructions2.png'); 
        [im , ~, ~] = imread(imageID);
        picIndex = Screen('MakeTexture', w, im);             
        [y,x,~] = size(im); %get size of image
        Screen('DrawTexture', w, picIndex, [0 0 x y], rect);   
        Screen('Flip',w);
        RestrictKeysForKbCheck([KbName('b')]); %different from first button so no quick advance.
        KbWait();
    end
    
    %% RUN TRIALS    
    Priority(9);
    timeStart = GetSecs;    
    for currentTrial = 1:totalTrials
        %Setup individual trial
        imageID = strcat('InputImages/',trialArray{:,3}{trialOrder(currentTrial)},'.png'); 
        [im , ~, ~] = imread(imageID);
        picIndex = Screen('MakeTexture', w, im);             
              
        RestrictKeysForKbCheck([KbName('Space')]);
        DrawFormattedText(w,['Are more of the dots ',trialArray{:,4}{trialOrder(currentTrial)},' (z) or ',trialArray{:,5}{trialOrder(currentTrial)},' (m)?'],'center','center',0);
        Screen('Flip',w);
        KbWait();

        Screen('DrawText',w,'+',rect(3)/2,rect(4)/2,0,0,0);
        Screen('Flip',w);
        WaitSecs(250/1000);
        Screen('Flip',w);
        
        [y,x,~] = size(im); %get size of image
        Screen('DrawTexture', w, picIndex, [0 0 x y], rect);   
        Screen('Flip',w);
       
        rt=0; %#ok<NASGU>
        kdown = 0;
        keyCode = 0;
        RestrictKeysForKbCheck([KbName(key1) KbName(key2) KbName('q')]);
        T1 = GetSecs;
        while((kdown == 0))
            [keyIsDown, ~, keyCode] = KbCheck;
            kdown=keyIsDown;
            T2 = GetSecs;
            rt = (T2-T1)*1000;
            if(rt >= isi)
                Screen('Flip',w);
            end
        end
        T2 = GetSecs;
        Screen('Flip',w);
        buttonPressed = find(keyCode);
        rt = (T2-T1)*1000;
 
        correct = 0;
        if((buttonPressed==KbName(key1))&&(trialArray{:,6}(trialOrder(currentTrial))>trialArray{:,7}(trialOrder(currentTrial))))  
            correct = 100;
        elseif((buttonPressed==KbName(key2))&&(trialArray{:,7}(trialOrder(currentTrial))>trialArray{:,6}(trialOrder(currentTrial))))  
            correct = 100;
        elseif(buttonPressed==KbName('q')) %the hard-coded quit button if you want to stop the experiment
            break;
        end
    
        output{1} = sub;
        output{2} = currentTrial;
        output{3} = (GetSecs-timeStart)/60;
        output{4} = isi;
        output{5} = trialArray{:,1}(trialOrder(currentTrial));
        output{6} = trialArray{:,3}{trialOrder(currentTrial)};
        output{7} = trialArray{:,6}(trialOrder(currentTrial));
        output{8} = trialArray{:,7}(trialOrder(currentTrial));
        output{9} = trialArray{:,8}(trialOrder(currentTrial));
        output{10} = trialArray{:,9}(trialOrder(currentTrial));
        output{11} = trialArray{:,10}(trialOrder(currentTrial));
        output{12} = trialArray{:,11}(trialOrder(currentTrial));
        output{13} = KbName(buttonPressed);
        output{14} = rt;
        output{15} = correct;
 
        writeData(output,fn);
    end
    Priority(0);
    
    %% Clean up
    Screen('Flip',w);
    DrawFormattedText(w,'You are done this part of the experiment! Please alert your experimenter.', 'center','center',0);
    Screen('Flip',w);
    WaitSecs(2);
    ListenChar(0);
    ShowCursor;
    Screen('CloseAll');
end

%DATAOUT FUNCTION
function [] = writeData(output,file)

    fid = fopen(file, 'a+');
    fprintf(fid, '%4d\t %4d\t %4d\t %4d\t %4d\t %4s\t %4d\t %4d\t %4f\t %4d\t %4d\t %4d\t %4s\t %4f\t %4d\n', ...
        output{1},...
        output{2},...
        output{3},...
        output{4},...
        output{5},...
        output{6},...
        output{7},...
        output{8},...
        output{9},...
        output{10},...
        output{11},...
        output{12},...
        output{13},...
        output{14},...
        output{15});
    fclose(fid);
end
