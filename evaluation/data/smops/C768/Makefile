# Makefile 
#
.SUFFIXES:
.SUFFIXES: .o .f90

 COMPILERF90    =       ifort -132
 F90FLAGS       =       -r8
 NETCDFMOD      =       -I/apps/netcdf/4.7.0/intel/18.0.5.274/include
 NETCDFLIB      =       -L/apps/netcdf/4.7.0/intel/18.0.5.274/lib -lnetcdf -lnetcdff


OBJS =	regrid_smopsSM_cgrid.o 

all:	regrid_smopsSM_cgrid.exe

.f90.o:
	$(COMPILERF90) -c $(F90FLAGS) $(FREESOURCE) $(NETCDFMOD) $(*).f90

regrid_smopsSM_cgrid.exe: $(OBJS)
	$(COMPILERF90) -o $(@) $(F90FLAGS) $(FREESOURCE) $(NETCDFMOD) $(OBJS) $(NETCDFLIB)

clean:
	rm -f *.o *.mod *.exe

