function locations = FindPeople(Persons, frame)
 locations = [];
 for i = 1:size(Persons, 2)
        p = Persons(i);
        if isActive(p, frame)
            [id, x,y] = getLocation(p, frame);
            locations = [locations; [id, x,y]]; %#ok<AGROW>
        end     
 end
end