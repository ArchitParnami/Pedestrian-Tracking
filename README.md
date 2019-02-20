# First take on pedestrian detection


![](https://raw.githubusercontent.com/ArchitParnami/Pedestrian-Tracking/master/Images/1.png)  
[Video](https://www.dropbox.com/s/n3vkx1bk88gsulk/students003.mp4?dl=0)

# Methods
## 1. [Motion-Based Multiple Object Tracking](https://www.mathworks.com/help/vision/examples/motion-based-multiple-object-tracking.html)
  I simply used the example MATLAB code on this video and obtained the following results.
https://www.dropbox.com/s/zq4zf82yfaizbpk/MotionBasedMultiObjectTrackingExample.m?dl=0

![](https://raw.githubusercontent.com/ArchitParnami/Pedestrian-Tracking/master/Images/2.png)  
[Video](https://www.dropbox.com/s/me5xytzjd59uecm/Results.mov?dl=0)

**How the Algorithm works?**

  - The detection of moving objects uses a background subtraction algorithm based on Gaussian mixture models. Morphological operations are applied to the resulting foreground mask to eliminate noise. Finally, blob analysis detects groups of connected pixels, which are likely to correspond to moving objects. 
  - The association of detections to the same object is based solely on motion. The motion of each track is estimated by a Kalman filter. The filter is used to predict the track's location in each frame, and determine the likelihood of each detection being assigned to each track.
  - Track maintenance becomes an important aspect of this example. In any given frame, some detections may be assigned to tracks, while other detections and tracks may remain unassigned. The assigned tracks are updated using the corresponding detections. The unassigned tracks are marked invisible. An unassigned detection begins a new track. 
  - Each track keeps count of the number of consecutive frames, where it remained unassigned. If the count exceeds a specified threshold, the example assumes that the object left the field of view and it deletes the track.  
  

**Analysis**
The method seems to work well in scenarios where pedestrians are not very close to each other. Since it uses connected component labeling in subsequent frames for tracking an object, it often labels close pedestrians as a single object. Therefore not suitable for pedestrian tracking in crowded places.



## 2. [Unsupervised Bayesian Detection of Independent Motion in Crowds](http://mi.eng.cam.ac.uk/~gjb47/crowds/)
  Found this paper, they have also done pedestrian tracking on this video. They have not shared the implementation of their algorithm but they have shared the results.

![](https://raw.githubusercontent.com/ArchitParnami/Pedestrian-Tracking/master/Images/3.png)    
[Video](https://www.dropbox.com/s/vwqjv734h9y85jp/Alan03_DivX.avi?dl=0)  

## 3[. Tracking Pedestrians from a Moving Car](https://www.mathworks.com/help/vision/examples/tracking-pedestrians-from-a-moving-car.html)

  

![](https://raw.githubusercontent.com/ArchitParnami/Pedestrian-Tracking/master/Images/4.png)    
[Video](https://www.dropbox.com/s/6vxe5uzruolnhwo/Results%20-%20TrackingPedestriansMovingCarExample.mov?dl=0)


**Analysis**
Method 3 overcomes the shortcomings of Method 1. As seen in the video, it seems sufficiently good at detecting occluded pedestrians. 

**Ground Truth**
I am able to interpolate ground truth from the given spline data. Here is how the ground truth looks like.

![](https://raw.githubusercontent.com/ArchitParnami/Pedestrian-Tracking/master/Images/5.png)  
[Video](https://www.dropbox.com/s/rcyhshpu0ylk7pv/GroundTruth.avi?dl=0)

![](https://raw.githubusercontent.com/ArchitParnami/Pedestrian-Tracking/master/Images/6.png)  
[Video](https://www.dropbox.com/s/nu97zf4x1xgn9s3/GTWithStationaryPeople.avi?dl=0)


**Comparing ground truth with Detection from method 3**
Play the video at 0.5x for more clarity

![](https://raw.githubusercontent.com/ArchitParnami/Pedestrian-Tracking/master/Images/7.png)  
[Video](https://www.dropbox.com/s/ugycmh15zi429l1/TrackingWithGT-1.avi?dl=0)



**Complete Ground Truth Video | Capturing GT Only Within The Region Of Interest**

https://drive.google.com/open?id=1JKWSW2MGsoQ1-RVWjrZCNfg3qLwXYAwf


[https://drive.google.com/open?id=1JKWSW2MGsoQ1-RVWjrZCNfg3qLwXYAwf](https://drive.google.com/open?id=1JKWSW2MGsoQ1-RVWjrZCNfg3qLwXYAwf)



# Evaluation
![](https://raw.githubusercontent.com/ArchitParnami/Pedestrian-Tracking/master/Images/8.png)  
[Video](https://www.dropbox.com/s/m7cll3l57k4g2ko/Evaluation.avi?dl=0)


Radius = 100

**Representation:**
Yellow → Ground Truth  
Blue → False Negative  
**Green & Red → Detections → Lower Center of the Bounding Box**  

  Green → True Positive  
  Red    →  False Positive  

![](https://raw.githubusercontent.com/ArchitParnami/Pedestrian-Tracking/master/Images/9.png)  
[Video](https://www.dropbox.com/s/h4hhuucjp5vwjqb/Evaluation_True_Positives.avi?dl=0)

![](https://raw.githubusercontent.com/ArchitParnami/Pedestrian-Tracking/master/Images/10.png)  
[Video](https://www.dropbox.com/s/cbfxcsuxl7lj108/Evaluation_False_Negatives.avi?dl=0)

![](https://raw.githubusercontent.com/ArchitParnami/Pedestrian-Tracking/master/Images/11.png)  
[Video](https://www.dropbox.com/s/pc9om1dgedbdw6w/Evaluation_False_Positives.avi?dl=0)

![](https://raw.githubusercontent.com/ArchitParnami/Pedestrian-Tracking/master/Images/12.png)  
[Video](https://www.dropbox.com/s/6funh9j18aq71p0/Evaluation_All.avi?dl=0)






**Detection Method and Results:** MASK-RCNN

https://github.com/ArchitParnami/Pedestrian-Tracking/blob/master/Evaluation/results_student.json


****
**Method for mapping Detection to GT**

- Let there be **m** GT and  **n**  Detections, then there are **k = min(m,n)** closest pairs
- A Closest pair is pair of GT and a Detection, such that they have shortest distance to each other.
- A Pair is Considered a Match / True Positive if the distance between GT and Detection is within a radius ‘R’  else it is a False Positive.

**Results**

| **Radius** | **Average Recall** | **Average Precision** | **Average F1 Score** |
| ---------- | ------------------ | --------------------- | -------------------- |
| 120        | 62.23              | 95.109                | 75.32                |
| **100**    | **61.28**          | **93.72**             | **74.10**            |
| 80         | 60.13              | 92.00                 | 72.72                |


Average precision and average accuracy are calculated  by taking average of results from all the frames excluding first and last frame. 
Total Frames = 5405  
Precision = T.P / (T.P + F.P)  
Recall = T.P / Number of GT  
F1 = 2 * (P*R) / (P+R)  

