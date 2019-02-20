classdef Person
    properties
    id
    xtSpline
    ytSpline
    startFrame
    endFrame
    end
    methods
        function obj = Person(id, x, y, frames)
            [obj.xtSpline, obj.ytSpline] = ParametricSpline(x,y, frames);
            obj.startFrame = frames(1);
            obj.endFrame = frames(end);
            obj.id = id;
        end
        
        function status = isActive(obj, frameNo)
            status = frameNo >= obj.startFrame && frameNo <= obj.endFrame;
        end
        
        function [id, x, y] = getLocation(obj, frameNo)
            if frameNo >= obj.startFrame && frameNo <= obj.endFrame
                x = ppval(obj.xtSpline, frameNo);
                y = ppval(obj.ytSpline, frameNo);
                id = obj.id;
            else
                error('Person not in frame');
            end 
        end
    end
end