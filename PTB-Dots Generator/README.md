#PTB-Dots Generator (ptbdotsgen.m)

Darko Odic (http://odic.psych.ubc.ca) <br />
Last Edit: 30/July/2015 <br />

This Psychtoolbox script is used to generate and save random dot stimuli for Approximate Number System. To display these images, use the PTB-Dots Display script, included with this. By default, it generates two sets of dots: blue and yellow, but this can be changed to accommodate any number of dots. You can use this readme as a general guide to using the program (further details can be found commented in the MATLAB code). 

## Important Note
In the past, I have had issues with the `GetImage` command of PTB-3 on PCs. Generally, the function will both prevent the Flip command from running correctly and will only save the background of the screen. I have never figured out the reason why. If you are experiencing problems using this script with Windows/PC, please try using it on a Mac. 

## Quick Overview
To run the script and save image files, you need to adjust two things:

1. **Change config.txt file**: this file contains some very basic information that is required for generating images, including:
  * `debug` ("on" or "off"): the debug mode runs the program in windowed mode (so you can read the console errors). It is recommended you run this mode the first time you try out the script. Keep in mind that images saved in debug mode will not be at the resolution of the full screen, and thus will be streched by the display program.
  * `numberArray` array (default: [20,10;10,20;18,12;12,18;24,20;20,24;22,10;10,22]): the list of numbers/ratios that will be presented, separated by semicolons. For example [20,10;10,20] means that the participant will always see either 20 yellow and 10 blue or 10 yellow and 20 blue dots. *Make sure that there are no spaces between the commas or semicolons when you type in these values, as this will cause the line to not be read in properly*. 
  * `allowedVariability` in percent (default 40): the maximum percent that one dot can be different from the default size. Higher variability means more heterogenous sizes between the dots. In general, 20 - 50% is a good number. 
  * `defaultSizePercentScreen` in percent (default: 2): the default cumulative size of the dots in each set (percent of total used screen size is used to make the size scalable with different drawRect options). Typically this will range from 0.5 - 3.0, depending on the total number of dots. 
  * `imagesPerBin' (default: 5): the number of fully balanced images that will be saved. For example, if you have the default 6 ratios x 2 area congruency = 12 bins * 5 imagesPerBin = 60 images total. 
  * `color1rgb` and `color2rgb` in RGB values (defaults: [255,255,0] amd [0,0,255]: the colours for the two sets of dots.
  
2. **Adjust drawRect in the Script**: a single parameter has to be adjusted directly in the script because it uses the `rect` variable. The `drawRect1` and `drawRect2` variables are the rectangles within which each set of dots will be drawn. By default, dots are drawn in overlapping space, but you can change these two variables to separate the dots so that blue dots are on one side and yellow on the other. A future version may include these in the config file.

Once the images are generated into the /OutputImages/ folder, copy and paste the entire thing (including imagestats.txt) into the /InputImages/ folder of the PTB-Dots Display script.

## Basic Overview of Functions
The script has four functions:

1. `ptbdotsgen`: this is the main function through which the image save.
  * This function takes no inputs.
  * This function gives no outputs, but uses all the `Screen()` functions and terminates the script. 

2. `writeData`: helper function for outputting properties of images.
  * This function takes as input the `output` structure defined at the end of each trial (see `output`) and the `fn` file, defined at the start of the script.
  * It will then write the designated columns to the file.

3. `drawDots`: the function used to jitter the size of the dots, place them on the screen, and make sure that the correct number is on the screen without overlap in the dots. This function is complicated and for a full overview see comments in the script itself.
  * There are many inputs, but the most relevant ones are the `numberSet` (which specifies the number of dots, e.g., [5,10] would draw 5 yellow and 10 blue dots), and the `drawRectSet` (which specifies the location of each set, e.g., [rect, rect] would draw both sets across the entire screen). 
  * It has one direct output: `didIt`, which returns a boolean depending on whether the function succesfully made the dots and placed them on the screen without overlap (it may fail if, e.g., there are too many big dots that simply can't fit on the screen). 
  
4. `checkOverlap`: helper function for checking if any pairs of XY coordinates (i.e., two dots) overlap or not. 
  * This function takes as input three XY pairs.
  * It outputs a boolean if the first pair overlaps with second two pairs. 

## If you need more than two sets of dots (advanced)
Increasing the number of dots will require some familiarity with the script, because many little things will need to be changed. The script is designed to work with two sets, but it can be adjusted to three or four if needed. On the big level, adjust the following:

1. **Change config.txt**: you will need to add `color3rgb` and `color3string` as new lines (the order doesn't matter). Add `key3` if needed. You will need to add new numbers to the `numberArray` (after a comma, before the semicolon). 

2. **Change loading of config**: you will need to create/load new variables called `drawRect3`, `color3rgb`, and (optionally) `color3string`. Simply copy and paste existing variables and adjust to match the name in the config file.

3. **Change `drawDots`**: you will need add `trialNumber3` to `[trialNumber1, trialNumber2]`, `drawRect3` to that line, `color3rgb` to that line, and `trialArea3` to that one, Make sure these additions stay as array inputs. The `drawDots` function will automatically generate and save the third set if these inputs are correct. 
