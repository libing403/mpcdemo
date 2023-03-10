function t=calc_displacement(az,dist,flyH)
Tx = dist * sind(az) * 3284 / (flyH  ) ;
Ty =  dist * cosd(az)  * 3284  / (flyH ) ;
t = [Tx; Ty; 1];