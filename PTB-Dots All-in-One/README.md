#PTB-Dots All-in-One

Darko Odic (http://odic.psych.ubc.ca)

This Psychtoolbox script is used to generate random dot stimuli for Approximate Number System experiments. By default, it generates two sets of dots: blue and yellow, but this can be changed to accomodate any number of dots. You can use this readme as a general guide to using the program (further details can be found commented in the MATLAB code).

## Quick Overview
To run the script as an experiment, you need to adjust three things.

1. **Change config.txt file**: this file contains some very basic information that is required for running your program, including:
  * Turning `debug` "on" or "off". The debug mode runs the program in windowed mode (so you can read the console errors) and skips introductions.
  * Set `pracSN` number. This number is for your "practice" runs and signifiacntly shortens the experiment.
  * Set `isi` value. This is the amount of time the dots stay on the screen for.
  * Set `trialsPerBin` value. This is the number of fully balanced trials that occur. For example, if you have 6 ratios x 2 area congruency = 12 bins * 20 trialsPerBin = 240 trials.
  * Set `color1rgb` and `color2rgb`. These are the colours for the two sets of dots. Add more if needed by making new line.
  * Set `key1` and `key2`. These are the keys used for answering in your task. Add more if needed by making new line. 
  
2. **Change Instructions**: the instructions presented to the participant are in the /Instructions/ folder. They are easiest to generate in Powerpoint. Once done, save your slides as images. Depending on your screen resolution, you may have to change the slide size so that the image is not compressed or streched. The instructions included are vanilla standard instructions we give to adult participants.

3. **Adjust a few Script Parameters**: there are a number of parameters that can be adjusted directly in the script, rather than the config file (a future edit will add these to the config file, instead). These include:
  * Line 42: change name of data output file.
  * Line 65: the `drawRect` variable is the rectangle within which the dots will be drawn. By default, dots are drawn in overlapping space, but you can create two `drawRect` variables that separate the dots so that blue dots are on one side and yellow on the other. 
  * Line 66: the `defaultArea` is the default *cumulative area* of all the dots drawn together. Adjust this to make the dots bigger or smaller.
  * Line 237: the `allowedVariability` variable is the maximum percent that one dot can be different from the default size. Higher variability means more heterogenous sizes between the dots. 

## Basic Overview of Functions
The script has four functions:

1. `ansDiscrimination`: this is the main function through which the entire experiment runs.
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
