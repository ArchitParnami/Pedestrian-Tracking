%make ground truth code visible
addpath('../groundtruthprocessing');
videoFile ='../groundtruthprocessing/students003.avi';
jsonFile = 'results_student.json'; 

%detections
results = read_json(jsonFile);
people_class = 1;
output_frames = results.frames;
names = fieldnames(output_frames);

%Ground Truth
Persons = ProcessSplineData();

radius = 5;%plotting circle radius
ROI = [20, 20, 680 536];% Region of Interest
total_precision = 0;
total_recall = 0;

%outputVideo = VideoWriter(fullfile(pwd, 'Evaluation_All.avi'));
%open(outputVideo);

video = VideoReader(videoFile);
videoPlayer = vision.VideoPlayer;
count = 1;

while hasFrame(video)
    
    %find coordinates of detections in this frame
    data = output_frames.(names{count});
    indexs = find(data.class_ids == people_class);
    detections = data.rois(indexs, :);
    h = detections(:, 3) - detections(:,1);
    w = detections(:, 4) - detections(:,2);
    %boxes = [detections(:, [2,1]), w, h];
    points = [detections(:,2)+round(w/2), detections(:,3)];
    indexes = getLocationsInROI(points, ROI);
    points = points(indexes, :);
    r = ones(size(points,1), 1) * radius;
    circles_detections = [points r]; 
    
    %find ground truth in this frame
    locations = FindPeople(Persons, count-1);
    ids = locations(:,1);
    locs = locations(:,[2,3]);
    indexes = getLocationsInROI(locs, ROI);
    locs = locs(indexes, :);
    ids = ids(indexes, :);
    r = ones(size(locs,1), 1) * radius;
    circles_GT = [locs r]; 
    
    %map ground truth with detections
    [match_indexs, matches] = find_closest(locs, points, 100);
    tp_pos = matches(:, 1) ~= -1;
    true_positives = matches(tp_pos,:);
    false_negatives = locs(~tp_pos, :);
    total_false_negatives = size(false_negatives, 1);
    
    r = ones(size(true_positives,1), 1) * radius;
    circle_true_positivies = [true_positives r];
    
    r = ones(size(false_negatives,1), 1) * radius;
    circle_false_negatives = [false_negatives r];
    
    total_detections = size(points,1);
    total_true_positives = size(true_positives,1);
    total_false_positives = total_detections - total_true_positives;
    precision = total_true_positives / total_detections;
    
    false_positives = points;
    false_positives(match_indexs, :) = [];
    r = ones(size(false_positives,1), 1) * radius;
    circle_false_positives = [false_positives r];
    
    total_GT = size(locs, 1);
    recall = total_true_positives / total_GT;
    text_precision = ['Precision:' num2str(precision*100,'%0.2f') '%'];
    text_recall =    ['Recall    :' num2str(recall*100,'%0.2f') '%'];
    text_frame =     ['Frame :' num2str(count)];
    text_GT =        ['People:  ' num2str(total_GT)];
    text_detections =['Detections:' num2str(total_detections)];
    text_tp = ['TP:' num2str(total_true_positives)];
    text_fp = ['FP:' num2str(total_false_positives)];
    text_fn = ['FN:' num2str(total_false_negatives)];
    
    frame = readFrame(video);
    frame = insertShape(frame, 'Rectangle', ROI, 'Color', 'Yellow');
    frame = insertShape(frame, 'FilledCircle', circle_true_positivies, 'Color','Green');
    frame = insertShape(frame, 'FilledCircle', circle_false_negatives, 'Color', 'Blue');
    frame = insertShape(frame, 'FilledCircle', circle_false_positives, 'Color', 'Red');
    
    frame = insertText(frame, [216, 23], text_frame);
    frame = insertText(frame,[216, 45], text_GT);
    frame = insertText(frame,[300 23],text_precision);
    frame = insertText(frame,[300 45],text_recall);
    frame = insertText(frame,[435 23],text_detections);
    frame = insertText(frame,[416 45], text_tp);
    frame = insertText(frame,[460 45], text_fp);
    frame = insertText(frame,[494 45], text_fn);
    
    %frame = insertShape(frame, 'FilledCircle', circles_GT);
    %frame = insertShape(frame, 'FilledCircle', circles_detections, 'Color','Red');
    %frame = insertShape(frame, 'Rectangle', boxes, 'Color', 'Red');
    %frame = insertObjectAnnotation(frame, 'Circle', circles_GT,  ids);
   
    %skip first and last frame in calculations
    if count ~= 1 && count ~= 5405
        total_precision = total_precision + precision;
        total_recall = total_recall + recall;
    end
   
    %writeVideo(outputVideo, frame);
    
    videoPlayer(frame);
    count = count + 1;
   
    %uncomment to proceed frame by frame
    %waitforbuttonpress;
    
    if ~isOpen(videoPlayer)
        break;
    end
    
end

release(videoPlayer);
%close(outputVideo);

avg_recall = (total_recall / (count-2)*100);
avg_precision = (total_precision / (count-2)*100);
disp("Avg Recall: " + num2str(avg_recall));
disp("Avg Precision: " + num2str(avg_precision));

%maps GT to Detections
function [match_indexs, matches] = find_closest(GT, points, radius)
    numberGTs = size(GT,1);
    numberPoints = size(points, 1);
    matches = zeros(size(GT));
    match_indexs = [];
    distance_matrix = zeros(numberPoints, numberGTs);
    for i = 1:size(GT,1)
        a = (GT(i,1) - points(:,1)) .^ 2;
        b = (GT(i,2) - points(:,2)) .^ 2;
        d = (a + b) .^ (1/2);
        distance_matrix(:,i) = d;
    end
    
    cols = 1:numberGTs;
    maxClosestPairs = min(numberGTs, numberPoints);
    pair_count = 0;
    
    while pair_count < maxClosestPairs
        done = [];
        for i = 1:size(cols,2)
            [v1, row] = min(distance_matrix(:, cols(i)));
            [~, col] = min(distance_matrix(row, :));
        
            if cols(i) == col && v1 ~= inf
                distance_matrix([1:row-1 row+1:end], col) = inf;
                distance_matrix(row, [1:col-1 col+1:end]) = inf;
                pair_count = pair_count + 1;
                done = [done, i];
            end
        end
        cols(done) = [];
    end
    
    for i = 1:size(GT, 1)
        [val, row] = min(distance_matrix(:, i));
        if val <= radius
            matches(i,:) = points(row, :);
            match_indexs = [match_indexs row];
        else
            matches(i,:) = [-1, -1];
        end
    end
    
end

%decodes json file
function results = read_json(fname)
    fid = fopen(fname); 
    raw = fread (fid);
    str = char(raw'); 
    fclose(fid); 
    results = jsondecode(str);
end

%filter locations in ROI
function indexs = getLocationsInROI(locations, ROI)
 ROI(3) = ROI(3) + ROI(1);
 ROI(4) = ROI(4) + ROI(2);
 indexs = find(locations(:,1) > ROI(1) & locations(:,1) < ROI(3) & locations(:,2) > ROI(2) & locations(:,2) < ROI(4));           
end
