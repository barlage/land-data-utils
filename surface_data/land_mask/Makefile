# Makefile 
#
.SUFFIXES:
.SUFFIXES: .o .f90

COMPILERF90    =       ifx
F90FLAGS       =       
NETCDFMOD      =       -I${netcdf_fortran_ROOT}/include
NETCDFLIB      =       -L${netcdf_fortran_ROOT}/lib -lnetcdff

OBJS =	create_land_fraction_30s.o

all:	create_land_fraction_30s.exe

.f90.o:
	$(COMPILERF90) -c $(F90FLAGS) $(NETCDFMOD) $(*).f90

create_land_fraction_30s.exe: $(OBJS)
	$(COMPILERF90) -o $(@) $(F90FLAGS) $(OBJS) $(NETCDFLIB)

clean:
	rm -f *.exe *.o

