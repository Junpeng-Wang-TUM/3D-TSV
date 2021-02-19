function hd = DrawSeedPoints()
	global axHandle_;
	global seedPointsHistory_;	
	hd = plot3(axHandle_, seedPointsHistory_(:,1), seedPointsHistory_(:,2), ...
		seedPointsHistory_(:,3), '.k', 'LineWidth', 2, 'MarkerSize', 6);
	hold(axHandle_, 'on');
end