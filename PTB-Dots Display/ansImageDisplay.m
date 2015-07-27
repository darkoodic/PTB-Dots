%ANS Image Display
%Darko Odic
%UBC Centre for Cognitive Development
%Sep 3, 2014
function [] = ansImageDisplay()
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
    if(strcmp(inputCells{2}{strcmp('debug',inputCells{1})},'on'))
        ListenChar(0);
        sub = input('Subject number:   ', 's');
        isi = str2num(inputCells{2}{strcmp('isi',inputCells{1})});    
        trialsPerBin = str2num(inputCells{2}{strcmp('trialsPerBin',inputCells{1})});
        Screen('Preference','SkipSyncTests',1);
        [w,rect]=Screen('OpenWindow',max(Screen('screens')),[127 127 127],[0 0 800 600]);
    else
        prompt = {'Subject Number:', 'ISI', 'TrialsPerBin'};
        defaults = {'999', inputCells{2}{strcmp('isi',inputCells{1})}, inputCells{2}{strcmp('trialsPerBin',inputCells{1})}};
        answer = inputdlg(prompt, 'ANS Discrimination', 1, defaults);
        [sub, isi, trialsPerBin] = deal(answer{:});
        isi = str2num(isi);
        trialsPerBin = str2num(trialsPerBin);
        Screen('Preference','SkipSyncTests',1);
        [w,rect]=Screen('OpenWindow',max(Screen('screens')),[127 127 127]);
        ListenChar(2);
    end
    Screen('TextFont', w, 'Helvetica');
    Screen('TextSize', w, 24);
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    %% MAKE DATA FILE  
    fn = strcat('Data/ANSDiscrimination', '_', datestr(now, 'mmdd'),'_', sub,'.xls');

    fid = fopen(fn, 'a+');
    sub = str2num(sub); %#ok<ST2NM>
    fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\n', ...
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
    trialOrder = randperm(length(trialArray{:,1}));
    
    %OPEN SCREEN
    if(strcmp(inputCells{2}{strcmp('debug',inputCells{1})},'on'))
        Screen('Preference','SkipSyncTests',1);
        [w,rect]=Screen('OpenWindow',max(Screen('screens')),[127 127 127],[0 0 800 600]);
        ListenChar(0);
    else
        [w,rect]=Screen('OpenWindow',max(Screen('screens')),[127 127 127]);
        ListenChar(2);
    end
    Screen('Preference', 'TextRenderer', 0);
    Screen(w,'TextSize',30);
    Screen(w,'TextFont','Helvetica');
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    %TRIAL ARRAY
    if(sub == str2num(inputCells{2}{strcmp('pracSN',inputCells{1})}))
        totalTrials = 5;
    end
    
    Priority(9);
    timeStart = GetSecs;
    %% Run Trials
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
        RestrictKeysForKbCheck([KbName('z') KbName('m') KbName('q')]);
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
        if((buttonPressed==KbName('z'))&&(trialArray{:,6}(trialOrder(currentTrial))>trialArray{:,7}(trialOrder(currentTrial))))  
            correct = 100;
        elseif((buttonPressed==KbName('m'))&&(trialArray{:,7}(trialOrder(currentTrial))>trialArray{:,6}(trialOrder(currentTrial))))  
            correct = 100;
        elseif(buttonPressed==KbName('q'))
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

function[didIt] = drawDots(w, minDistance, numberSet, drawRectSet, colorSet, pixelsSet)
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
    allowedVariability = 40;
    errorThreshold = pixelsSet*0.05;
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
           % break;
            
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
end%function

function[overlapping] = checkOverlap(checkX, checkY,x1, y1, x2, y2)
    if((checkX>x1)&&(checkX<x2)&&(checkY>y1)&&(checkY<y2))
        overlapping = true;
    else
        overlapping = false;
    end
end
