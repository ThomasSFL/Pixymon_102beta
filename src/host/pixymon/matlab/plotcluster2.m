% function [L, LX, LY] = plotcluster(Pixels)

e = .95;
d = 1.3;
d2 = 2.0;
d3 = 4.0;
minsat = .10;

pp = plotPix(Pixels);
pp = [pp(1:end, 1), -pp(1:end, 2)+mean(pp(1:end, 2)), -pp(1:end, 3)];

if size(pp, 1)>0
	meanx = mean(pp(1:end, 2));
	meanx = tweakmean(meanx);
	meany = mean(pp(1:end, 3));	
	meany = tweakmean(meany);
	angle = atan2(meany, meanx);
	slope = tan(angle);
	uv = [cos(angle), sin(angle)];
	D = dot(repmat(uv, size(pp, 1), 1), [pp(1:end, 2), pp(1:end, 3)], 2);
	dmax = max(D);
	vec = uv*(dmax+0.1);
	lx = [0; vec(1)];
	ly = [0; vec(2)];

	anglep = angle+pi/2;	
	ps = tan(anglep);
	lp = [ps, slope*meanx - ps*meanx];
	dx = abs(.1*cos(anglep));
	lpx = [meanx - dx; meanx + dx];
	lpy = lpx*lp(1) + lp(2);

	% find upper and lower major lines
	yu = iterateline([pp(1:end, 2), pp(1:end, 3)], [slope, 0], abs(.001/cos(angle)), e);
	yu = yu + abs(d*yu);
	lu = [slope, yu];
	lux = lx-yu*cos(angle)*sin(angle);
	luy = lux*slope+yu;
	
	yd = iterateline([pp(1:end, 2), pp(1:end, 3)], [slope, 0], -abs(.001/cos(angle)), e);
	yd = yd - abs(d*yd);
	ld = [slope, yd];
	ldx = lx-yd*cos(angle)*sin(angle);
	ldy = ldx*slope+yd;
	
	% find inner and outer major lines
	% if uv(2) is negative, we want to iterate up (positive), so -sign(uv(2))
	yl = iterateline([pp(1:end, 2), pp(1:end, 3)], lp, -sign(uv(2))*abs(.001/cos(anglep)), e);
	yl = yl + -sign(uv(2))*abs(d2*(yl-lp(2)));   
	xxl = yl/(slope-ps);
	yyl = xxl*slope;
	sat = dot(uv, [xxl, yyl]);
	if sat < minsat
		minl = uv*minsat;
		yl = minl(2) - ps*minl(1);    
	end
	ll = [ps, yl];
	llx = lpx - (yl-lp(2))*cos(anglep)*sin(anglep);
	lly = llx*ps+yl;
	
	% if uv(2) is negative, we want to iterate down (negative), so sign(uv(2))
	yr = iterateline([pp(1:end, 2), pp(1:end, 3)], lp, sign(uv(2))*abs(.001/cos(anglep)), e);
	yr = yr - -sign(uv(2))*abs(d3*(yr-lp(2))); 
	lr = [ps, yr];
	lrx = lpx - (yr-lp(2))*cos(anglep)*sin(anglep);
	lry = lrx*ps+yr;
	
	if ll(2) > lr(2)
		L = [lu; ld; ll; lr];
	else
		L = [lu; ld; lr; ll];
	end
	
	LX = [lux; ldx; llx; lrx];
	LY = [luy; ldy; lly; lry];
	
	plot(pp(1:end, 2), pp(1:end, 3), '.', lx, ly, '-', lpx, lpy, '-', lux, luy, '-', ldx, ldy, '-', llx, lly, '-', lrx, lry, '-');
	axis equal;
end
