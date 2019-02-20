function [xt, yt] = ParametricSpline(x, y, frames)
xt = spline(frames, x); 
yt = spline(frames, y); 
end