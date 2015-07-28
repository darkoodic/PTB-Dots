#PTB-Dots All-in-One (ptbdotsaio.m)

Darko Odic (http://odic.psych.ubc.ca)
Last Edit: 28/July/2015

This Psychtoolbox script is used to generate random dot stimuli for Approximate Number System experiments. By default, it generates two sets of dots: blue and yellow, but this can be changed to accomodate any number of dots. You can use this readme as a general guide to using the program (further details can be found commented in the MATLAB code).

## Quick Overview
To run the script as an experiment, you need to adjust three things.

1. **Change config.txt file**: this file contains some very basic information that is required for running your program, including:
  * Turning `debug` "on" or "off". The debug mode runs the program in windowed mode (so you can read the console errors) and skips introductions.
  * Set `pracSN` number. This number is for your "practice" runs and signifiacntly shortens the experiment.
  * Set `isi` value. This is the amount of time the dots stay on the screen for.
  * Set `numberArray`. This is the list of numbers that will be presented, separated by semicolons. For example [20,10;10,20] means that the participant will always see either 20 yellow and 10 blue or 10 yellow and 20 blue dots. *Make sure that there are no spaces between the commas or semicolons when you type in these values, as this will cause the line to not be read in properly*. 
  * Set `allowedVariability`: the `allowedVariability` variable is the maximum percent that one dot can be different from the default size. Higher variability means more heterogenous sizes between the dots. In general, 20 - 50 is a good number. 
  * Set `defaultSizePercentScreen`. The default size of the dot is set to be the percent of the used screen. Typically this will range from 0.5 - 3.0, depending on the total number of dots. 
  * Set `trialsPerBin` value. This is the number of fully balanced trials that occur. For example, if you have 6 ratios x 2 area congruency = 12 bins * 20 trialsPerBin = 240 trials.
  * Set `color1rgb` and `color2rgb`. These are the colours for the two sets of dots. Add more if needed by making new line.
  * Set `key1` and `key2`. These are the keys used for answering in your task. Add more if needed by making new line. 
  
2. **Adjust drawRect in the Script**: a single parameter has to be adjusted directly in the script because it uses the `rect` variabile. The `drawRect1` and `drawRect2` variables are the rectangles within which each set of dots will be drawn. By default, dots are drawn in overlapping space, but you can change these two variables to separate the dots so that blue dots are on one side and yellow on the other. A future version may include these in the config file.

3. **Change Instructions**: the instructions presented to the participant are in the /Instructions/ folder. They are easiest to generate in Powerpoint. Once done, save your slides as images. Depending on your screen resolution, you may have to change the slide size so that the image is not compressed or streched. The instructions included are vanilla standard instructions we give to adult participants.


## Basic Overview of Functions
The script has four functions:

1. `ptbdotsaio`: this is the main function through which the entire experiment runs.
  * This function takes no inputs.
  * This function gives no outputs.

2. `writeData`: helper function for outputting data.
  * This function takes as input the `output` structure defined in lines 162-177 and the `fn` file.
  * It will then write the designated columns to the file.

3. `drawDots`: the function used to jitter the size of the dots, place them on the screen, and make sure that the correct number is on the screen without overlap in the dots. This function is complicated and for full overview see comments.
  * There are many inputs, but the most relevant ones are the `numberSet` (which specifies the number of dots, e.g., [5 10] would draw 5 yellow and 10 blue dots), and the `drawRectSet` (which specifies the location of each set, e.g., [rect, rect] would draw both sets across the entire screen). 
  * It has no direct outputs, but it has a Screen command at bottom that places each dot on the screen when it is ready.

4. `checkOverlap`: helper function for checking if any pairs of XY coordinates (i.e., two dots) overlap or not. 
  * This function takes as input three XY pairs.
  * It outputs a boolean if the first pair overlaps with second two pairs. 

## If you need more than two sets of dots
To increase the number of dot sets (e.g., make blue, yellow, and red dots) adjust the following:

1. **Change config.txt**: you will need to add `color3rgb` and `color3string` as new lines (the order doesn't matter). Add `key3` if needed. You will need to add new numbers to the `numberArray` (after a comma, before the semicolon). 

2. **Change loading of config**: you will need to create/load new variables called `drawRect3`, `color3rgb`, and `color3string`. Simply copy and paste existing functions and adjust to match the name in the config file.

3. **Change `drawDots`**: you will need add `trialNumber3` to the fourth input line, `drawRect3` to the fifth, `color3rgb` to the sixth, and `trialArea3` to the seventh, Make sure these additions stay as array inputs. The `drawDots` function will automatically generate the third set if these inputs are correct. 
