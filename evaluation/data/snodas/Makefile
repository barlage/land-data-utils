# Makefile 
#
.SUFFIXES:
.SUFFIXES: .o .f90

 COMPILERF90    =       ifort
 FREESOURCE     =       #-ffree-form  -ffree-line-length-none
 F90FLAGS       =       -init=huge -assume byterecl
 NETCDFMOD      =       -I${NETCDF}/include
 NETCDFLIB      =       -L${NETCDF}/lib -lnetcdf -lnetcdff

OBJS =	create_snodas_C96_conus_mapping.o

all:	create_snodas_C96_conus_mapping.exe

.f90.o:
	$(COMPILERF90) -c $(F90FLAGS) $(FREESOURCE) $(NETCDFMOD) $(*).f90

create_snodas_C96_conus_mapping.exe: $(OBJS)
	$(COMPILERF90) -o $(@) $(F90FLAGS) $(FREESOURCE) $(NETCDFMOD) $(OBJS) $(NETCDFLIB)

clean:
	rm -f *.o *.mod *.exe

#
# Dependencies:
#
