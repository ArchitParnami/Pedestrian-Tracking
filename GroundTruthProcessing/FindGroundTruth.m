videoFile = 'students003.avi';
video = VideoReader(videoFile);

Persons = ProcessSplineData();
count = 0;
radius = 5;

while hasFrame(video)
    frame = readFrame(video);
    %every 10th frame
    if count >= 0 && mod(count,10) == 0
        
        locations = FindPeople(Persons, count);
        ids = locations(:,1);
        locs = locations(:,[2,3]);
        r = ones(size(locs,1), 1) * radius;
        locs = [locs r];
        frame = insertShape(frame, 'FilledCircle', locs);
        frame = insertObjectAnnotation(frame, 'Circle', locs,  ids);

        imshow(frame);
        title(string(count+1));
        [x,y] = ginput;
        close;
        disp([x,y]);
    end
    
    count = count + 1;
   
end