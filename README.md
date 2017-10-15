# mcv-m1-team03

## **Master in Computer Vision - M1 - Traffic Sign Detection/Recognition Project**

*Authors: Àlex Vicente, Àlex Palomo, Joan Sintes and Roger Marí (2017)*

**Week 1:**

    Fill the 'test_2017' and 'train_2017' folders with the test and train splits. 
    Go to the 'week1' folder and execute the 'main.m' script with Matlab. 
    The 'main.m' script contains the code for tasks 1, 2, 3 and 4.
    The different strategies that we used to solve each task are commented in detail in the scripts. 
    In order to generate the masks for the test split, execute the 'test.m' script with Matlab. 
    The output binary masks will be stored as png files in the following directory: test_2017/test/mask.

**Week 2:**

    Fill the 'test_2017' and 'train_2017' folders with the test and train splits. 
    Go to the 'week2' folder and execute the 'task2.m' script to check task 2. 
    The implementation of the  morphological operators required for task 1 can be found in the /morphological_operators folder.
    Execute the 'main.m' script to check tasks 3 and 4.
    The different strategies that we used to solve each task are commented in detail in the scripts. 
    In order to generate the masks for the test split, execute the 'test_methodX.m' scripts.
    
    test_method1: HCbCr color segmentation with hand picked thresholds + post-processing
    test_method2: Histogram back-projection color segmentation (with Cb and Cr channels from YCbCr space) + post-processing.
    test_method3: Histogram back-projection color segmentation (with Hue and Saturation channels from HSV space) + post-processing.
