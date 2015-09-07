% PTB-Dots Kids (GitHub Version)
% Darko Odic (http://odic.psych.ubc.ca)
% University of British Columbia

% Last Update: Sep/6/2015
% Please read README.md before using. 
function [] = ptbdotskids()
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
        feedback = inputCells{2}{strcmp('feedback',inputCells{1})};
        progressBar = inputCells{2}{strcmp('progressBar',inputCells{1})};
        Screen('Preference','SkipSyncTests',1);
        [w,rect]=Screen('OpenWindow',max(Screen('screens')),[127 127 127],[0 0 800 600]);
    else
        prompt = {'Subject Number:', 'Feedback (on/off):', 'Progress Bar (on/off):'};
        defaults = {'999', inputCells{2}{strcmp('feedback',inputCells{1})}, inputCells{2}{strcmp('progressBar',inputCells{1})}};
        answer = inputdlg(prompt, 'Kid ANS', 1, defaults);
        [sub, feedback, progressBar] = deal(answer{:});
        Screen('Preference','SkipSyncTests',1);
        [w,rect]=Screen('OpenWindow',max(Screen('screens')),[127 127 127]);
        ListenChar(2);
    end
    Screen('TextFont', w, 'Helvetica');
    Screen('TextSize', w, 24);
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
   
    %% MAKE DATA FILE
    fn = strcat('Data/PTBDotsKids', '_', datestr(now, 'mmdd'),'_', sub,'.xls');
    fid = fopen(fn, 'a+');
    sub = str2num(sub); %#ok<ST2NM>
    fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\n', ...
        'SubNum',...
        'DidIt',...
        'TrialNum',...
        'TimeStamp',...
        'ISI',...
        'Feedback',...
        'Character1',...
        'Character2',...
        'Color1',...
        'Color2',...
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

    %% DOT & TRIAL PROPERTIES
    % With kids we have to spatially separate the dots for extra cues
    % and in case they are colour-blind. This means we cannot have more
    % than two colours.
    leftDrawRect = [rect(3)*0.10, rect(4)*0.15, rect(3)*0.40, rect(4)*0.85];
    rightDrawRect = [rect(3)*0.60, rect(4)*0.15, rect(3)*0.90, rect(4)*0.85];
    leftFrameRect = [rect(3)*0.05, rect(4)*0.10, rect(3)*0.45, rect(4)*0.90];
    rightFrameRect = [rect(3)*0.55, rect(4)*0.10, rect(3)*0.95, rect(4)*0.90];
    color1rgb = str2num(inputCells{2}{strcmp('color1rgb',inputCells{1})});
    color2rgb = str2num(inputCells{2}{strcmp('color2rgb',inputCells{1})});
    color1string = inputCells{2}{strcmp('color1string',inputCells{1})};
    color2string = inputCells{2}{strcmp('color2string',inputCells{1})};
    key1 = inputCells{2}{strcmp('key1',inputCells{1})};
    key2 = inputCells{2}{strcmp('key2',inputCells{1})};
    allowedVariability = inputCells{2}{strcmp('allowedVariability',inputCells{1})}; %in percent +/- from default
   
    %Make sure ISI is nice and long for young kids
    isi = str2num(inputCells{2}{strcmp('isi',inputCells{1})});    
    
    %Load in two kid-friendly characters so kids don't have to say colours.
    %Default is spongebob and smurf, you can also load big bird and grover
    %or include your own (must have transparent back and specify file in config.txt). 
    character1 = inputCells{2}{strcmp('character1',inputCells{1})};
    character2 = inputCells{2}{strcmp('character2',inputCells{1})};
    
    %Optional freeze first trial for explanation
    freezeFirst = inputCells{2}{strcmp('freezeFirstTrial',inputCells{1})};
    
    %Optional progress bar so you know how close to end. This is helpful
    %for being able to motivate the child by showing them how close they
    %are to being done. 
    progressBarRect = [rect(3)*0.45, rect(4)*0.95, rect(3)*0.55, rect(4)*0.98];
    
    %the default size of the dot set is determined as % of the total screen
    %size; this allows to scale nicely if you change the draw rectangle or
    %if you do not run at full screen. 
    percentScreen = str2num(inputCells{2}{strcmp('defaultSizePercentScreen',inputCells{1})});
    defaultArea = (rect(3)*rect(4))*(percentScreen/100); 
       
    %CARTOON TEXTURES
    leftCharacter = strcat('Characters/',character1,'.png'); 
    [lim , ~, alpha] = imread(leftCharacter);
    lim(:,:,4) = alpha(:,:);
    [ly,lx,~] = size(lim); %get size of image
    leftCharacterIndex = Screen('MakeTexture', w, lim);      

    rightCharacter = strcat('Characters/',character2,'.png'); 
    [rim , ~, alpha] = imread(rightCharacter);
    rim(:,:,4) = alpha(:,:);
    [ry,rx,~] = size(rim); %get size of image
    rightCharacterIndex = Screen('MakeTexture', w, rim);    
    
    %TRIAL ARRAY
    if(sub == str2num(inputCells{2}{strcmp('pracSN',inputCells{1})}))
        trialsPerBin = 1;
    else
        trialsPerBin = str2num(inputCells{2}{strcmp('trialsPerBin',inputCells{1})});
    end
    numberArray = str2num(inputCells{2}{strcmp('numberArray',inputCells{1})});
    numberTimesArea1 = horzcat(numberArray, repmat(1,[length(numberArray),1])); %Area = 1, Congruent
    numberTimesArea2 = horzcat(numberArray, repmat(2,[length(numberArray),1])); %Area = 2, InCongruent
    
    trialArray = repmat(vertcat(numberTimesArea1,numberTimesArea2),[trialsPerBin,1]);
    totalTrials = length(trialArray);
    shuffledArray = trialArray(randperm(size(trialArray,1)),:);
    
    %First frame can be optionally set to freeze so that the displays can
    %be clearly shown to the kids. This is probably not needed for kids
    %older than 8. 
    if(strcmp(freezeFirst,'on'))
        Screen('FrameRect', w, color1rgb, leftFrameRect, 8);
        Screen('FrameRect', w, color2rgb, rightFrameRect, 8);
        Screen('DrawTexture', w, leftCharacterIndex, [0 0 lx ly], [rect(3)*0 rect(4)*0.80 rect(3)*0.12 rect(4)*1.0]);
        Screen('DrawTexture', w, rightCharacterIndex, [0 0 rx ry], [rect(3)*.92 rect(4)*0.80 rect(3)*1.00 rect(4)*1.0]);
        RestrictKeysForKbCheck([KbName('Space')]);
        Screen('Flip',w);
        KbWait();
        
        WaitSecs(250/1000);
        
        %Show a very easy ratio. 
        didIt = drawDots(...
            w,... %screen
            10,... %minDistance
            allowedVariability,... %allowed pixel variability
            [30,10],... %numberSet
            [leftDrawRect;rightDrawRect],... %drawRectSet, if identical then dots are intermixed
            [color1rgb; color2rgb],... %colorSet
            [18000, 6000]); %pixelsSet   
        Screen('FrameRect', w, color1rgb, leftFrameRect, 8);
        Screen('FrameRect', w, color2rgb, rightFrameRect, 8);
        Screen('DrawTexture', w, leftCharacterIndex, [0 0 lx ly], [rect(3)*0 rect(4)*0.80 rect(3)*0.12 rect(4)*1.0]);
        Screen('DrawTexture', w, rightCharacterIndex, [0 0 rx ry], [rect(3)*.92 rect(4)*0.80 rect(3)*1.00 rect(4)*1.0]);
        Screen('Flip',w);
        RestrictKeysForKbCheck([KbName('Space')]);
        KbWait();
        Screen('Flip',w);  
        WaitSecs(1);
    end
    
    %% RUN TRIALS
    Priority(9);
    timeStart = GetSecs;
    for currentTrial = 1:totalTrials
        %Setup individual trial
        trialNumber1= shuffledArray(currentTrial,1,:);
        trialNumber2 = shuffledArray(currentTrial,2,:);
        trialRatio = max(trialNumber1/trialNumber2, trialNumber2/trialNumber1);
        
        trialArea = shuffledArray(currentTrial,3,:);
        if(trialArea == 1) %Congruent
            if(trialNumber1>trialNumber2)
                trialArea1 = defaultArea;
                trialArea2 = defaultArea*(1/trialRatio);
            else
                trialArea1 = defaultArea*(1/trialRatio);
                trialArea2 = defaultArea;
            end
        else
            if(trialNumber1>trialNumber2)
                trialArea1 = defaultArea*(1/trialRatio);
                trialArea2 = defaultArea;
            else
                trialArea1 = defaultArea;
                trialArea2 = defaultArea*(1/trialRatio);
            end
        end
        
        Screen('FrameRect', w, color1rgb, leftFrameRect, 8);
        Screen('FrameRect', w, color2rgb, rightFrameRect, 8);
        Screen('DrawTexture', w, leftCharacterIndex, [0 0 lx ly], [rect(3)*0 rect(4)*0.80 rect(3)*0.12 rect(4)*1.0]);
        Screen('DrawTexture', w, rightCharacterIndex, [0 0 rx ry], [rect(3)*.92 rect(4)*0.80 rect(3)*1.00 rect(4)*1.0]);
        
        %Progress Bar   
        if(strcmp(progressBar,'on'))
            percentDone = (currentTrial-1)/totalTrials;
            xBar = progressBarRect(3) - progressBarRect(1);
            xBar = progressBarRect(1) + round(xBar*percentDone);
            Screen('FrameRect',w,[200 200 200],progressBarRect, 1);
            Screen('FillRect',w,[200 200 200],[progressBarRect(1), progressBarRect(2), xBar, progressBarRect(4)]);
        end
        RestrictKeysForKbCheck([KbName('Space')]);
        Screen('Flip',w);
        KbWait();
        
        WaitSecs(250/1000);
        didIt = drawDots(...
            w,... %screen
            10,... %minDistance
            allowedVariability,... %allowed pixel variability
            [trialNumber1,trialNumber2],... %numberSet
            [leftDrawRect;rightDrawRect],... %drawRectSet, if identical then dots are intermixed
            [color1rgb; color2rgb],... %colorSet
            [trialArea1, trialArea2]); %pixelsSet   
      
        Screen('FrameRect', w, color1rgb, leftFrameRect, 8);
        Screen('FrameRect', w, color2rgb, rightFrameRect, 8);
        Screen('DrawTexture', w, leftCharacterIndex, [0 0 lx ly], [rect(3)*0 rect(4)*0.80 rect(3)*0.12 rect(4)*1.0]);
        Screen('DrawTexture', w, rightCharacterIndex, [0 0 rx ry], [rect(3)*.92 rect(4)*0.80 rect(3)*1.00 rect(4)*1.0]);
        
        %Progress Bar       
        if(strcmp(progressBar,'on'))
            percentDone = (currentTrial-1)/totalTrials;
            xBar = progressBarRect(3) - progressBarRect(1);
            xBar = progressBarRect(1) + round(xBar*percentDone);
            Screen('FrameRect',w,[200 200 200],progressBarRect, 1);
            Screen('FillRect',w,[200 200 200],[progressBarRect(1), progressBarRect(2), xBar, progressBarRect(4)]);
        end
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
                Screen('FrameRect', w, color1rgb, leftFrameRect, 8);
                Screen('FrameRect', w, color2rgb, rightFrameRect, 8);
                Screen('DrawTexture', w, leftCharacterIndex, [0 0 lx ly], [rect(3)*0 rect(4)*0.80 rect(3)*0.12 rect(4)*1.0]);
                Screen('DrawTexture', w, rightCharacterIndex, [0 0 rx ry], [rect(3)*.92 rect(4)*0.80 rect(3)*1.00 rect(4)*1.0]);
                %Progress Bar       
                if(strcmp(progressBar,'on'))
                    percentDone = (currentTrial-1)/totalTrials;
                    xBar = progressBarRect(3) - progressBarRect(1);
                    xBar = progressBarRect(1) + round(xBar*percentDone);
                    Screen('FrameRect',w,[200 200 200],progressBarRect, 1);
                    Screen('FillRect',w,[200 200 200],[progressBarRect(1), progressBarRect(2), xBar, progressBarRect(4)]);
                end
                Screen('Flip',w);
            end
        end
        T2 = GetSecs;
        Screen('FrameRect', w, color1rgb, leftFrameRect, 8);
        Screen('FrameRect', w, color2rgb, rightFrameRect, 8);
        Screen('DrawTexture', w, leftCharacterIndex, [0 0 lx ly], [rect(3)*0 rect(4)*0.80 rect(3)*0.12 rect(4)*1.0]);
        Screen('DrawTexture', w, rightCharacterIndex, [0 0 rx ry], [rect(3)*.92 rect(4)*0.80 rect(3)*1.00 rect(4)*1.0]);    
        
        %Progress Bar       
        if(strcmp(progressBar,'on'))
            percentDone = (currentTrial-1)/totalTrials;
            xBar = progressBarRect(3) - progressBarRect(1);
            xBar = progressBarRect(1) + round(xBar*percentDone);
            Screen('FrameRect',w,[200 200 200],progressBarRect, 1);
            Screen('FillRect',w,[200 200 200],[progressBarRect(1), progressBarRect(2), xBar, progressBarRect(4)]);
        end
        Screen('Flip',w);
        buttonPressed = find(keyCode);
        rt = (T2-T1)*1000;
 
        correct = 0;
        if((buttonPressed==KbName(key1))&&(trialNumber1>trialNumber2))
            correct = 100;
        elseif((buttonPressed==KbName(key2))&&(trialNumber2>trialNumber1))  
            correct = 100;
        elseif(buttonPressed==KbName('q')) %hard-coded quit key
            break;
        end
            
        %% PLAY FEEDBACK
        % Optional but will read in sounds from /Sounds/ directory.
        % There are 10 variations on Correct and 2 on Wrong in order to
        % keep things interesting for the child (and with the expectation
        % that they will get most trials correct).
        if(strcmp(feedback,'on'))
            if(correct == 100);
                [sound, freq] = wavread(['Sounds/Correct',num2str(randsample(10,1)),'.wav']);
                soundBuff = sound';
                nrchannels = size(soundBuff,1); 
                pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);
                PsychPortAudio('FillBuffer', pahandle, soundBuff);
                PsychPortAudio('Start', pahandle, 1, 0, 1);
            else
                [sound, freq] = wavread(['Sounds/Wrong',num2str(randsample(2,1)),'.wav']);
                soundBuff = sound';
                nrchannels = size(soundBuff,1);
                pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);
                PsychPortAudio('FillBuffer', pahandle, soundBuff);
                PsychPortAudio('Start', pahandle, 1, 0, 1);
            end
        end

        output{1} = sub;
        output{2} = didIt;
        output{3} = currentTrial;
        output{4} = (GetSecs-timeStart)/60; %timestamp
        output{5} = isi;
        output{6} = feedback;
        output{7} = character1;
        output{8} = character2;
        output{9} = color1string;
        output{10} = color2string;
        output{11} = trialNumber1;
        output{12} = trialNumber2;
        output{13} = trialRatio;
        output{14} = trialArea1;
        output{15} = trialArea2;
        output{16} = trialArea;
        output{17} = KbName(buttonPressed);
        output{18} = rt;
        output{19} = correct;
 
        writeData(output,fn);
    end
    Priority(0);

    %% CLEAN UP
    if(strcmp(feedback,'on'))
        PsychPortAudio('Close', pahandle); %delete audio
    end
    Screen('Flip',w);
    DrawFormattedText(w,'Yay! All Done!', 'center','center',0);
    Screen('Flip',w);
    ListenChar(0);
    ShowCursor;
    Screen('CloseAll');
end

%DATAOUT FUNCTION
function [] = writeData(output,file)
    fid = fopen(file, 'a+');
    fprintf(fid, '%4d\t %4d\t %4d\t %4f\t %4f\t %4s\t %4s\t %4s\t %4s\t %4s\t %4d\t %4d\t %4f\t %4d\t %4d\t %4d\t %4s\t %4f\t %4d\n', ...
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
        output{15},...
        output{16},...
        output{17},...
        output{18},...
        output{19});
    fclose(fid);
end

function[didIt] = drawDots(w, minDistance, allowedVariability, numberSet, drawRectSet, colorSet, pixelsSet)
    %Task #1: initialize all the variables, including size of the screen we
    %are drawing to, the variability in the size of the dots, their
    %colours, etc.
    
    %Task #2: by default, all dots are uniform size; we have to jitter them
    %by the radius variability (make sure it is radius and not some other
    %value); but once we jitter them each randomly, there is a chance that
    %the set will be too big or too small; so we keep jittering until the
    %total size of the set is approximatelly the size of the specified
    %pixels set (this is of course made difficult by the fact they are
    %circles, so we have to leave some wiggle room)
    
    %Task #3: decide the position of each dot, making sure they do not
    %overlap and are as far apart as dictated by the min distance variable
    
    %CRITICAL: because this procedure does not guarantee a solution (e.g.,
    %the number of dots can't fit on the screen) we need to have break
    %procedures that time out the loops and effectively stop the function
    %from running; this is why the ditIt variable is returned. 
    
    errorThreshold = pixelsSet*0.05; %the % within which the total area doesn't have to exactly match specified
    defaultArea = pixelsSet./numberSet;
    defaultRadius = sqrt(defaultArea./pi);       
    
    didIt = true;
    
    addUpPixels = zeros(1,length(numberSet));
    tryAgain = 0;

    %TASK#1 FOR LOOP
    for currentSet = 1:length(numberSet)
        while((addUpPixels(currentSet)>(pixelsSet(currentSet)+errorThreshold(currentSet)))||(addUpPixels(currentSet)<(pixelsSet(currentSet)-errorThreshold(currentSet))))         
            %check if we have looped enough time to quit and not make it
            tryAgain = tryAgain +1;
            if(tryAgain>2000) %if it failed, it does not run the trial
                didIt=false;
                break;
            end
            
            %if we can still spin the loop, reset addUp, and move on
            addUpPixels(currentSet) = 0;            
            for currentDot = 1:numberSet(currentSet)
                random3 = round(rand()*allowedVariability); %jitter
                if(rand<0.5)
                    random3 = 100-random3(1);
                else
                    random3 = 100+random3(1);
                end
                radius(currentSet,currentDot) = round(defaultRadius(currentSet) * (random3/100)); %keeps track of all radii
                addUpPixels(currentSet) = addUpPixels(currentSet) + (pi*radius(currentSet,currentDot)^2);
            end%all dots are made, need to check if they add up right to totalPixel
        end%check if dots add up right and finalize set
    end%finalize all sets

    %DONE JITTERING, MOVE ON    
    %TASK 2: ASSIGN POSITIONS AND PRINT TO SCREEN
    if(didIt==true)%continue if all dots are made 
        for currentSet = 1:length(numberSet)
            minX = drawRectSet(currentSet,1);
            minY = drawRectSet(currentSet,2);
            maxX = drawRectSet(currentSet,3);
            maxY = drawRectSet(currentSet,4);
            minD = minDistance;
            
            dotSetX1(currentSet,1) = 0;
            dotSetX2(currentSet,1) = 0;
            dotSetY1(currentSet,1) = 0;
            dotSetY2(currentSet,1) = 0;

            for currentDot = 1:numberSet(currentSet)
                overlapping = true;
                counter = 0;

                while((overlapping == true)&&(counter<500))
                    rangeX = maxX-minX-(radius(currentSet,currentDot));
                    rangeY = maxY-minY-(radius(currentSet,currentDot));

                    random1 = round(rand(1)*rangeX+minX);
                    random2 = round(rand(1)*rangeY+minY);

                    x1 = random1;
                    y1 = random2;
                    x2 = round(x1 + (radius(currentSet,currentDot)*2));
                    y2 = round(y1 + (radius(currentSet,currentDot)*2));
                    [m,n]=size(dotSetX1);

                    for setsWithDots = 1:m
                        for previousDots = 1:n
                            dx1 = dotSetX1(setsWithDots,previousDots);
                            dy1 = dotSetY1(setsWithDots,previousDots);
                            dx2 = dotSetX2(setsWithDots,previousDots);
                            dy2 = dotSetY2(setsWithDots,previousDots);

                            if(checkOverlap(x1,y1,dx1-minD,dy1-minD,dx2+minD,dy2+minD)==true)
                                overlapping = true;
                                counter = counter +1;
                                break;%breaks for previousDots
                            elseif(checkOverlap(x1,y2,dx1-minD,dy1-minD,dx2+minD,dy2+minD)==true)
                                overlapping = true;
                                counter = counter +1;
                                break;%breaks for previousDots
                            elseif(checkOverlap(x2,y1,dx1-minD,dy1-minD,dx2+minD,dy2+minD)==true)
                                overlapping = true;
                                counter = counter +1;
                                break;%breaks for previousDots
                            elseif(checkOverlap(x2,y2,dx1-minD,dy1-minD,dx2+minD,dy2+minD)==true)
                                overlapping = true;
                                counter = counter +1;
                                break;%breaks for previousDots
                            elseif(checkOverlap(dx1,dy1,x1-minD,y1-minD,x2+minD,y2+minD)==true)
                                overlapping = true;
                                counter = counter +1;
                                break;%breaks for previousDots
                            elseif(checkOverlap(dx1,dy2,x1-minD,y1-minD,x2+minD,y2+minD)==true)
                                overlapping = true;
                                counter = counter +1;
                                break;%breaks for previousDots
                            elseif(checkOverlap(dx2,dy1,x1-minD,y1-minD,x2+minD,y2+minD)==true)
                                overlapping = true;
                                counter = counter +1;
                                break;%breaks for previousDots
                            elseif(checkOverlap(dx2,dy2,x1-minD,y1-minD,x2+minD,y2+minD)==true)
                                overlapping = true;
                                counter = counter +1;
                                break;%breaks for previousDots
                            else
                                overlapping = false;
                            end
                        end
                        if(overlapping==true)
                            break;%breaks for setswithdots
                        end
                    end%forsetswithdots
                end%while overlapping
                if(counter==500)
                    didIt=false;
                    Screen('Clear');
                    %'Broke Counter'
                    break;
                end;
                if(overlapping==false)
                    dotSetX1(currentSet,currentDot) = x1;
                    dotSetX2(currentSet,currentDot) = x2;
                    dotSetY1(currentSet,currentDot) = y1;
                    dotSetY2(currentSet,currentDot) = y2;
                    Screen('FillOval',w,colorSet(currentSet,:),[dotSetX1(currentSet,currentDot),dotSetY1(currentSet,currentDot),dotSetX2(currentSet,currentDot),dotSetY2(currentSet,currentDot)]);
                end;
            end%currentDot for loop
            if(didIt==false)
                Screen('Clear');
                break;
            end;
        end%currentSet for loop
    end%draw dot function
end%

function[overlapping] = checkOverlap(checkX, checkY,x1, y1, x2, y2)
    if((checkX>x1)&&(checkX<x2)&&(checkY>y1)&&(checkY<y2))
        overlapping = true;
    else
        overlapping = false;
    end
end
