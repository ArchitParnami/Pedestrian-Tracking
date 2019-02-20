videoFile = 'students003.avi';
video = VideoReader(videoFile);
videoPlayer = vision.VideoPlayer;
%outputVideo = VideoWriter(fullfile(pwd, 'output.avi'));
%open(outputVideo);
Persons = ProcessSplineData();
count = 0;
radius = 5;
ROI = [20, 20, 680 536];
while hasFrame(video)
    frame = readFrame(video);
    frame = insertShape(frame, 'Rectangle', ROI, 'Color', 'Red');
    
    locations = FindPeople(Persons, count);
    locations = getLocationsInROI(locations, ROI);
    ids = locations(:,1);
    locs = locations(:,[2,3]);
    r = ones(size(locs,1), 1) * radius;
    locs = [locs r];
    frame = insertShape(frame, 'FilledCircle', locs);
    frame = insertObjectAnnotation(frame, 'Circle', locs,  ids);
       
    %writeVideo(outputVideo, frame);
    
    videoPlayer(frame);
    count = count + 1;
    
    if ~isOpen(videoPlayer)
        break;
    end
end

release(videoPlayer);
%close(outputVideo);

function locs = getLocationsInROI(locations, ROI)
 ROI(3) = ROI(3) + ROI(1);
 ROI(4) = ROI(4) + ROI(2);
 locs = locations(locations(:,2) > ROI(1) & locations(:,2) < ROI(3) & ...
                  locations(:,3) > ROI(2) & locations(:,3) < ROI(4), :);
              
end