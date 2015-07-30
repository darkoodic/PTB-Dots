% PTB-Dots Generator (GitHub Version)
% Darko Odic (http://odic.psych.ubc.ca)
% University of British Columbia

% Last Update: July/30/2015
% Please read README.md before using. 
% You require a /OutputImages/ folder for this script to work.

% Note: I have previously had issues with the 'GetImage' function working
% properly on Windows/PC (the function just captured blank screen, as if it
% triggered too late). If you are having issues with this script, please
% try using the script on a Mac. 
function [] = ptbdotsgen()
    HideCursor;
    clear all;
    warning off;
    rand('twister',sum(100*clock));
    AssertOpenGL;
    KbName('UnifyKeyNames');
    
    %% OPEN CONFIG FILE
    inputFile = fopen('config.txt');
    inputCells = textscan(inputFile,'%s\t %s\n');

    %% MAKE OUTPUT FILE (this file is critical for the ptbdotsdisplay script)
    fn = strcat('OutputImages/imageStats.txt');
    fid = fopen(fn, 'a+');
    fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\n', ...
        'ImageNum',...
        'DidIt',...
        'ImageName',...
        'Color1String',...
        'Color2String',...
        'Number1',...
        'Number2',...
        'Ratio',...
        'Area1',...
        'Area2',...
        'AreaCongruency');
    fclose(fid);
    
    %% OPEN SCREEN
    % Note that both debug being on and off turns off Sync Tests (due to Mac issues)
    % If it doesn't cause problems on your machine, I would turn Sync Tests back on. 
    if(strcmp(inputCells{2}{strcmp('debug',inputCells{1})},'on'))
        Screen('Preference','SkipSyncTests',1);
        [w,rect]=Screen('OpenWindow',max(Screen('screens')),[127 127 127],[0 0 800 600]);
        trialsPerBin = 2;
    else
        Screen('Preference','SkipSyncTests',1);
        [w,rect]=Screen('OpenWindow',max(Screen('screens')),[127 127 127]);
        trialsPerBin = str2num(inputCells{2}{strcmp('imagesPerBin',inputCells{1})});
    end
    Screen('Preference', 'TextRenderer', 0);
    Screen(w,'TextSize',30);
    Screen(w,'TextFont','Helvetica');
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    %% DOT & TRIAL PROPERTIES
    drawRect1 = [rect(3)*0.15, rect(4)*0.15, rect(3)*0.85, rect(4)*0.85];
    drawRect2 = [rect(3)*0.15, rect(4)*0.15, rect(3)*0.85, rect(4)*0.85];
    color1rgb = str2num(inputCells{2}{strcmp('color1rgb',inputCells{1})});
    color2rgb = str2num(inputCells{2}{strcmp('color2rgb',inputCells{1})});
    color1string = inputCells{2}{strcmp('color1string',inputCells{1})};
    color2string = inputCells{2}{strcmp('color2string',inputCells{1})};
    allowedVariability = inputCells{2}{strcmp('allowedVariability',inputCells{1})}; %in percent +/- from default
    
    %the default size of the dot set is determined as % of the total screen
    %size; this allows to scale nicely if you change the draw rectangle or
    %if you do not run at full screen. 
    percentScreen = str2num(inputCells{2}{strcmp('defaultSizePercentScreen',inputCells{1})});
    defaultArea = (drawRect1(3)*drawRect1(4))*(percentScreen/100); 
    
    %NUMBER OF IMAGES ARRAY
    %2.0; 1.50; 1.20; 1.11; 1.06
    numberArray = str2num(inputCells{2}{strcmp('numberArray',inputCells{1})});
    numberTimesArea1 = horzcat(numberArray, repmat(1,[length(numberArray),1])); %Area = 1, Congruent
    numberTimesArea2 = horzcat(numberArray, repmat(2,[length(numberArray),1])); %Area = 2, InCongruent
    
    imagesArray = repmat(vertcat(numberTimesArea1,numberTimesArea2),[trialsPerBin,1]);
    totalImages = length(imagesArray);
  
    Priority(9);
    %% RUN TRIALS
    for currentTrial = 1:totalImages
        %Setup individual trial
        trialNumber1= imagesArray(currentTrial,1,:);
        trialNumber2 = imagesArray(currentTrial,2,:);
        trialRatio = max(trialNumber1/trialNumber2, trialNumber2/trialNumber1);
        
        trialArea = imagesArray(currentTrial,3,:);
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
                     
        didIt = drawDots(...
            w,... %screen
            10,... %minDistance in pixels
            allowedVariability,... %allowed pixel variability
            [trialNumber1,trialNumber2],... %numberSet
            [drawRect1;drawRect2],... %drawRectSet, if identical then dots are intermixed
            [color1rgb; color2rgb],... %colorSet
            [trialArea1, trialArea2]); %pixelsSet   
       Screen('Flip',w);
        
        if(didIt == 1)
            % Save Display as Image
            % Note: .png will give you higher quality than .jpg
            % The filename doesn't have to be this descriptive, but it is
            % important that it doesn't lead to repeats
            imageArray = Screen('GetImage',w,rect);
            filename = strcat('ansGen-',num2str(trialNumber1),'-',num2str(trialNumber2),'-',num2str(trialArea),'-',num2str(currentTrial));
            filepath = strcat('OutputImages/',filename,'.png');
            imwrite(imageArray, filepath);
        end
        
        output{1} = currentTrial;
        output{2} = didIt;
        output{3} = filename;
        output{4} = color1string;
        output{5} = color2string;
        output{6} = trialNumber1;
        output{7} = trialNumber2;
        output{8} = trialRatio;
        output{9} = trialArea1;
        output{10} = trialArea2;
        output{11} = trialArea;     
        writeData(output,fn);
    end

    %% Clean up
    Screen('Flip',w);
    DrawFormattedText(w,'All done.', 'center','center',0);
    Screen('Flip',w);
    WaitSecs(1);
    ShowCursor;
    Screen('CloseAll');
end

%DATAOUT FUNCTION
function [] = writeData(output,file)
    fid = fopen(file, 'a+');
    fprintf(fid, '%4d\t %4d\t %4s\t %4s\t %4s\t %4d\t %4d\t %4f\t %4d\t %4d\t %4d\n', ...
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
        output{11});
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
