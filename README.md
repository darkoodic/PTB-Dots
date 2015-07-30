# PTB-Dots
Psychtoolbox scripts used for generating, saving, and displaying approximate number system (ANS) dot displays. 

## Created By
Darko Odic (http://odic.psych.ubc.ca) <br />
Department of Psychology <br />
University of British Columbia <br />

We welcome contributions and revisions to this code, as it could definitely be optimized further! If interested, fork, change, send pull request. If you don't like git, clone/download, revise, then send me an email.

## Quick Start

1. Make sure you have downloaded the latest version of <a href="http://www.mathworks.com/products/matlab/">MATLAB</a> and <a href="http://psychtoolbox.org/">Psychtoolbox</a>. These scripts were built and tested on Psychtoolbox-3.0.12, but should work fine with later versions, as well. 
2. <a href="https://github.com/darkoodic/PTB-Dots/archive/master.zip">Download</a> or clone the repo (`git clone https://github.com/darkoodic/PTB-Dots.git`). This will give you all three script types that you can see below.
3. Open any of the three scripts in MATLAB, run the green arrow and enjoy. If there are any issues, we recommend going into the config.txt file and changing `debug` to "on". This will allow you to easily see errors in the console. 

## Versions
There are three different versions of the script:

1. **PTB-Dots All-In-One** (`ptbdotsaoi.m`): To generate and immediately display randomized dot displays following various parameters, like changes in size, ratio, etc. This is the most common way for testing adults and children and generally has everything you need. Further information on this script is available in that folder's README.md file. 
2. **PTB-Dots Generator** (`ptbdotsgen.m`): To generate and save individual trials as .png or .jpeg files for later use and consistency across subjects. Further information on this script is available in that folder's README.md file. 
3. **PTB-Dots Display** (`ptbdotsdisplay.m`): To display pre-made images generated by the program. This is useful for paradigms that require precise control over the kinds of stimuli (e.g., confidence hysteresis paradigms). Further information on this script is available in that folder's README.md file. 

## Using this script for kids?
We are currently in the process of making a fourth script type that can be easily used with children. Stay tuned.

## License
Code released under the MIT license.
