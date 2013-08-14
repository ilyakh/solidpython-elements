

translate() {
	union() {
		translate(v = [0, 0, 0]) {
			difference() {
				difference() {
					difference() {
						union() {
							translate(v = [3.6250000000, 0, 0]) {
								difference() {
									cube(center = true, size = [30.2500000000, 35, 20]);
									rotate(a = 90, v = [0, 1, 0]) {
										cylinder(h = 60.5000000000, r = 3.5000000000, center = true);
									}
								}
							}
							translate(v = [0, 0, 0]) {
								difference() {
									cube(center = true, size = [4.7500000000, 35, 20]);
									rotate(a = 90, v = [0, 1, 0]) {
										cylinder(h = 9.5000000000, r = 2.6750000000, center = true);
									}
								}
							}
							translate(v = [-3.6250000000, 0, 0]) {
								difference() {
									cube(center = true, size = [30.2500000000, 35, 20]);
									rotate(a = 90, v = [0, 1, 0]) {
										cylinder(h = 60.5000000000, r = 3.5000000000, center = true);
									}
								}
							}
						}
						translate(v = [0, 0, 10.0000000000]) {
							cube(center = true, size = [97.5000000000, 35, 20]);
						}
					}
				}
				union() {
					translate(v = [-13.0000000000, 0, 0]) {
						translate(v = [0, -13.0000000000, 0]) {
							cylinder($fn = 32, h = 100, r = 3.0000000000, center = true);
						}
						translate(v = [0, 13.0000000000, 0]) {
							cylinder($fn = 32, h = 100, r = 3.0000000000, center = true);
						}
					}
					translate(v = [13.0000000000, 0, 0]) {
						translate(v = [0, -13.0000000000, 0]) {
							cylinder($fn = 32, h = 100, r = 3.0000000000, center = true);
						}
						translate(v = [0, 13.0000000000, 0]) {
							cylinder($fn = 32, h = 100, r = 3.0000000000, center = true);
						}
					}
				}
			}
		}
	}
}
/***********************************************
******      SolidPython code:      *************
************************************************
 
# -*- coding: utf-8 -*-

from core import *


class Support( Element ):

    def create_inner( self ):

        length = self.s.x - ( self.p.get('core_length') )
        radius = self.p.get('inner_radius')

        return difference() (
            cube( [ length, self.s.y, self.s.z ], center=True ),
            rotate(90, [0,1,0]) (
                cylinder(
                    h=length *2,
                    r=radius,
                    center=True
                )
            )
        )

    def create_core( self ):
        length = self.p.get('core_length')
        radius = self.p.get('core_radius')

        return difference() (
            cube( [ length, self.s.y, self.s.z ], center=True ),
            rotate(90, [0,1,0]) (
                cylinder(
                    h=length *2,
                    r=radius,
                    center=True
                )
            )
        )

    def create_outer( self ):
        length = self.s.x - ( self.p.get('core_length') )
        radius = self.p.get('outer_radius')

        return difference() (
            cube( [ length, self.s.y, self.s.z ], center=True ),
            rotate(90, [0,1,0]) (
                cylinder(
                    h=length *2,
                    r=radius,
                    center=True
                )
            )
        )

    def create_bolt_hole( self ):
        return cylinder(
            self.p.get('bolt_hole_radius'),
            100,
            center=True,
            segments=self.p.get("segments")
        )

    def create_bolt_holes( self ):



        x_offset_from_center = self.s.half('x') - \
                             (self.p.get('bolt_hole_radius') + \
                              self.p.get('bolt_hole_outer_offset'))

        y_offset_from_center = self.s.half('y') - \
                             (self.p.get('bolt_hole_radius') + \
                              self.p.get('bolt_hole_outer_offset'))

        return union() (
            left( x_offset_from_center ) (
                back( y_offset_from_center ) ( self.create_bolt_hole() ),
                forward( y_offset_from_center ) ( self.create_bolt_hole() )
            ),
            right( x_offset_from_center ) (
                back( y_offset_from_center ) ( self.create_bolt_hole() ),
                forward( y_offset_from_center ) ( self.create_bolt_hole() )
            ),
        )

    def create_first_layer( self ):

        total_length = sum([
            self.p.get('inner_length'),
            self.p.get('core_length'),
            self.p.get('outer_length'),
        ])

        half_core_length = self.p.get('core_length') / 2.0

        return difference() (
            difference() (
                union() (
                    translate(
                        [self.p.get('inner_length') / 2.0 + half_core_length , 0, 0]
                    ) ( self.create_inner() ),
                    translate([0,0,0]) ( self.create_core() ),
                    translate(
                        [-(self.p.get('outer_length') / 2.0 + half_core_length), 0, 0]
                    ) ( self.create_outer() )
                ),
                translate([ 0, 0, self.s.half('z') ]) (
                    cube([total_length * 10.0, self.s.y, self.s.z], center=True )
                )
            )
        )

    def apply_bolt_holes( self, target ):
        return difference() (
            target,
            self.create_bolt_holes()
        )

    def create_second_layer( self ):
        return mirror([1, 0, 0]) (
            self.create_first_layer()
        )

    def create( self ):

        spacing = 30

        # position with a equidistant point-cloud

        return union() (
            translate( [0, 0, 0] ) (
                self.apply_bolt_holes( self.create_first_layer() )
            ),

            # translate( [ self.s.x + spacing, 0, 0] ) (
            #    self.apply_bolt_holes( self.create_second_layer() )
            # ),


            # translate( [0, self.s.y + spacing, 0] ) (
            #
            #     translate( [ 0, 0, 0 ] ) (
            #         self.apply_bolt_holes(
            #             rotate( 90, [0,0,1] ) (
            #                 self.create_first_layer()
            #             )
            #         )
            #     ),
            #
            #     translate( [ self.s.x + spacing, 0, 0 ] ) (
            #         self.apply_bolt_holes(
            #             rotate( 90, [0,0,1] ) (
            #                 self.create_second_layer()
            #             )
            #         )
            #     )
            # )
            #
        )






if __name__ == "__main__":


    e = Support(
        Size( 35, 35, 20 ),
        parameters={
            'segments': 32,
            'outer_length': 2.5 ,
            'outer_radius': 7.0 / 2.0,
            'core_length': 4.75,
            'core_radius': 5.35 / 2.0,
            'inner_length': 2.5,
            'inner_radius': 7.0 / 2.0,
            'bolt_hole_radius': 3.0,
            'bolt_hole_outer_offset': 1.5
        }
    )
    e.create()

    scad_render_to_file( e.put(), "project.scad" ) 
 
***********************************************/
                            
