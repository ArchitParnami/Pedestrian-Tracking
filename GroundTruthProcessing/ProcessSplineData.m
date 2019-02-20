function Persons = ProcessSplineData()
    datafile = 'SplineData.txt';
    fid = fopen(datafile);
    tline = fgetl(fid);
    numberOfSplines = str2num(tline);  %#ok<*ST2NM>
    Persons = [];
    for i = 1:numberOfSplines
        tline = fgetl(fid);
        K = strsplit(tline);
        id = str2num(K{1});
        numberOfControlPoints = str2num(K{2});
        X = zeros(1, numberOfControlPoints);
        Y = zeros(1, numberOfControlPoints);
        Frames = zeros(1, numberOfControlPoints);
        for j = 1:numberOfControlPoints
            tline = fgetl(fid);
            C = strsplit(tline);
            X(j) = str2double(C{1});
            Y(j) = str2double(C{2});
            Frames(j) = str2num(C{3});
        end
        p = Person(id, X, Y, Frames);
        Persons = [Persons, p]; %#ok<AGROW>
    end
    fclose(fid);
end